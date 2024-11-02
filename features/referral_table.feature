Feature: Update the referral table with created referral data

@pre_authenticated
Scenario:
  Given I am on the event page "Fake Event"
  And I have the following seats
  | category  | section | total_count |
  | 1         | 1       | 80          |
  And I have the following guests
  | first_name | last_name | email | affiliation | category | section | alloted_seats | commited_seats | guest_commited |
  | xx         | xx        | y@yy  | xx          | 1        | 1       | 1             | 1              | 1              |
  When we visit the new page for the referral
  When we enter 'aaaaaaa@aaaaaaa.???' into 'Friend's Email Address'
  When we click the 'Submit'
  Then there will be one additional referral tuple generated with expected attibute on the referee email with 'aaaaaaa@aaaaaaa.???'
  When we have a referral with 5 tickets bought
  When we visit the show page for this event
  When visit the edit referral page
  When we enter 10 into 'Input'
  When we click submit
  Then the reward value will be updated to 50



          