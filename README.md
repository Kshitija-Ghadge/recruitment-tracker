# Recruitment Tracker (Salesforce)
A recruitment management app built on Salesforce, covering both admin configuration and custom development.

<img width="1900" height="747" alt="Dashboard" src="https://github.com/user-attachments/assets/6ed19c00-bd62-42bd-96d8-bef463342aaa" />


## Features
- Duplicate application and closed-position checks (Apex trigger, handler pattern)
- Auto-close a position when openings are filled
- Batch + Schedulable job to close expired positions
- LWC dashboard: position search, applications table with inline edit, apply form
- Lightning Message Service for cross-component communication
- Record-triggered Flow for offer emails
- Permission sets, role hierarchy, reports and dashboard

## Tech Stack
Apex, Lightning Web Components, Flow, SOQL, SFDX

## Data Model
- **Position__c**: openings, status, closing date, filled count (roll-up)
- **Candidate__c**: email, phone, experience, skills
- **Application__c**: master-detail to Position, lookup to Candidate, status, expected salary

## Project Structure
- `force-app/main/default/classes`: Apex classes and test classes
- `force-app/main/default/triggers`: ApplicationTrigger
- `force-app/main/default/lwc`: Lightning Web Components
- `force-app/main/default/flows`: Offer email flow
