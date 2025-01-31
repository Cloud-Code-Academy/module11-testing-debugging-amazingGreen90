@isTest
private class LeadTriggerHandlerTest {
    @isTest
    static void testhandleTitleNormalization_INSERT(){
        List<Lead> leads = new List<Lead>();
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Tester', Title = 'vp', Company = 'CCA');
        leads.add(lead);

        Test.startTest();
        insert leads;
        Test.stopTest();

        Lead insertedLead = [SELECT Id, Title FROM Lead WHERE Id = :lead.Id];

        Assert.areEqual('Vice President', insertedLead.Title, 'Title should be Vice President');
    }

    @isTest
    static void testhandleTitleNormalization_UPDATE(){
        //insert leads
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(FirstName = 'Test', LastName = 'Tester', Title = 'vp', Company = 'CCA'));
        leads.add(new Lead(FirstName = 'Test2', LastName = 'Tester2', Title = 'head of department', Company = 'CCA'));
        leads.add(new Lead(FirstName = 'Test2', LastName = 'Tester2', Title = 'chief', Company = 'CCA'));
        leads.add(new Lead(FirstName = 'Test2', LastName = 'Tester2', Title = 'jr', Company = 'CCA'));

        insert leads;

        //update leads
        List<Lead>updatedLeads = new List<Lead>();
        List<Lead> leadsToUpdate = [SELECT Id, Title FROM Lead];
        for (Lead l : leadsToUpdate) {
            l.Title = 'mgr';
            updatedLeads.add(l);
        }

        Test.startTest();
        update updatedLeads;
        Test.stopTest();

        List <Lead> updatedLeadList = [SELECT Id, Title FROM Lead WHERE Id = :updatedLeads];
        for (Lead l : updatedLeadList) {
            Assert.areEqual('Manager', l.Title, 'Title should be Manager');
        }
    }

    @isTest
    static void testhandleAutoLeadScoring_INSERT(){
        List<Lead> leads = new List<Lead>();
        // ALL FIELDS NEEDED = 18
        leads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Title = 'vp', 
            Company = 'CCA',
            LeadSource = 'Web',
            Email = 'cca@testemail.com',
            Phone = '1111111111',
            Industry = 'Technology'
            ));
        // NO EMAIL, NO SOURCE = 15
        leads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Title = 'vp', 
            Company = 'CCA',
            Phone = '1111111111',
            Industry = 'Technology'
            ));
        // NO PHONE, NO EMAIL, NO SOURCE = 10
        leads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Title = 'vp', 
            Company = 'CCA',
            Industry = 'Technology'
            ));
        // NO PHONE, NO EMAIL, NO SOURCE, NO INDUSTRY = 0
        leads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Title = 'vp', 
            Company = 'CCA'
            ));
        // ALL FIELDS NEEDED + ADDING LEAD SCORE VALUE HIGHER THAN 18 = 18
        leads.add(new Lead(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Title = 'vp', 
            Company = 'CCA',
            LeadSource = 'Web',
            Email = 'cca@testemail.com',
            Phone = '1111111111',
            Industry = 'Technology',
            Lead_Score__c = 25
            ));

        Test.startTest();
        insert leads;
        Test.stopTest();

        List<Lead> insertedLeads = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :leads];

        Assert.areEqual(18, insertedLeads[0].Lead_Score__c, 'Lead Score should be 18');
        Assert.areEqual(15, insertedLeads[1].Lead_Score__c, 'Lead Score should be 15');
        Assert.areEqual(10, insertedLeads[2].Lead_Score__c, 'Lead Score should be 10');
        Assert.areEqual(0, insertedLeads[3].Lead_Score__c, 'Lead Score should be 0');
        Assert.areEqual(18, insertedLeads[4].Lead_Score__c, 'Lead Score should be 18');

    }

    @isTest
    static void testhandleAutoLeadScoring_UPDATE(){ 
        // Insert a single Lead with all required fields to start at a score of 18
        Lead testLead = new Lead(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Title = 'vp', 
            Company = 'CCA',
            LeadSource = 'Web',
            Email = 'test@testemail.com',
            Phone = '1111111111',
            Industry = 'Technology'
        );
    
        insert testLead;
    
        // Retrieve the inserted Lead
        testLead = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :testLead.Id];
        // Verify initial Lead Score is 18
        Assert.areEqual(18, testLead.Lead_Score__c, 'Initial Lead Score should be 18');
        Test.startTest();
        // Increase Lead Score manually to 25, update record
        testLead.Lead_Score__c = 25;
        update testLead;
        // Fetch the updated Lead
        testLead = [SELECT Lead_Score__c FROM Lead WHERE Id = :testLead.Id];
        // Lead Score is reset to 18
        Assert.areEqual(18, testLead.Lead_Score__c, 'Lead Score should be reset to 18 if set higher than the max allowed');
        // Remove Industry (-10 points, now 8)
        testLead.Industry = null;
        update testLead;
        testLead = [SELECT Lead_Score__c FROM Lead WHERE Id = :testLead.Id];
        Assert.areEqual(8, testLead.Lead_Score__c, 'Lead Score should now be 8 after removing Industry');
        // Remove Phone (-5 points, now 3)
        testLead.Phone = null;
        update testLead;
        testLead = [SELECT Lead_Score__c FROM Lead WHERE Id = :testLead.Id];
        Assert.areEqual(3, testLead.Lead_Score__c, 'Lead Score should now be 3 after removing Phone');
        // Remove Email (-3 points, now 0)
        testLead.Email = null;
        testLead.LeadSource = null;
        update testLead;
        testLead = [SELECT Lead_Score__c FROM Lead WHERE Id = :testLead.Id];
        Assert.areEqual(0, testLead.Lead_Score__c, 'Lead Score should now be 0 after removing Email and Lead Source');
        Test.stopTest();
    }

    @isTest
    static void testhandleLeadAutoConvert_INSERT(){
        //CREATE ACCTS
        Account acc = new Account(Name = 'LeadTestAcct');
        insert acc;
        //CREATE CONTACTS
        List <Contact> contacts = new List <Contact>();
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id, Email = 'testSingleMatch@email.com'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = acc.Id, Email = 'testMultipleMatch@email.com'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact3', AccountId = acc.Id, Email = 'testMultipleMatch@email.com'));
        contacts.add(new Contact(FirstName = 'Test', LastName = 'Contact3', AccountId = acc.Id, Email = 'test@email.com'));
        insert contacts;
        //CREATE LEADS
        List <Lead> leads = new List<Lead>();
        leads.add(new Lead(FirstName = 'Lead', LastName = 'Test', Company = 'LeadCompany', Email = 'testSingleMatch@email.com'));
        leads.add(new Lead(FirstName = 'Lead2', LastName = 'Test2', Company = 'LeadCompany2', Email = 'testMultipleMatch@email.com'));
        leads.add(new Lead(FirstName = 'Lead4', LastName = 'Test4', Company = 'LeadCompany4', Email = 'testNoMatch@email.com'));

        insert leads;

        List <Lead> insertedleads = [SELECT Id, isConverted, Email FROM Lead WHERE Id IN :leads];

        Assert.areEqual(true, insertedleads[0].isConverted, 'Lead should be converted');
        Assert.areEqual(false, insertedleads[1].isConverted, 'Lead should NOT be converted');
        Assert.areEqual(false, insertedleads[2].isConverted, 'Lead should NOT be converted');
    }
    @isTest
    static void testhandleLeadAutoConvert_UPDATE() {
        // CREATE ACCOUNTS
        Account acc = new Account(Name = 'LeadTestAcct');
        insert acc;
        
        // CREATE CONTACTS
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id, Email = 'testSingleMatch@email.com'),
            new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = acc.Id, Email = 'testMultipleMatch@email.com'),
            new Contact(FirstName = 'Test', LastName = 'Contact3', AccountId = acc.Id, Email = 'testMultipleMatch@email.com')
        };
        insert contacts;
        
        // CREATE LEADS
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'Lead', LastName = 'Test', Company = 'LeadCompany', Email = 'testNoMatch@email.com'),
            new Lead(FirstName = 'Lead2', LastName = 'Test2', Company = 'LeadCompany2', Email = 'testNoMatch2@email.com')
        };
        insert leads;
    
        // UPDATE LEADS
        for (Lead l : leads) {
            if (l.LastName == 'Test') {
                l.Email = 'testSingleMatch@email.com';
            } else if (l.LastName == 'Test2') {
                l.Email = 'testMultipleMatch@email.com'; 
            }
        }
        update leads;
        List<Lead> updatedLeads = [SELECT Id, isConverted, Email FROM Lead WHERE Id IN :leads];
        Assert.areEqual(true, updatedLeads[0].isConverted, 'Lead should be converted after update');
        Assert.areEqual(false, updatedLeads[1].isConverted, 'Lead should NOT be converted due to multiple matches');
    }
}