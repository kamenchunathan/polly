# Poll Creating and Answering website

<!--toc:start-->
- [Poll Creating and Answering website](#poll-creating-and-answering-website)
  - [TODO](#todo)
<!--toc:end-->

## TODO
  - [x] create and style the page not found page
  - [x] fetch poll data for the id specified in the URL
     - [x] Extract selectionSets into a local module
     - [x] create SelectionSets to get specific polls based on id
  - [ ] Do authentication and detect if a poll has already been answered by a user
    - [x] Create a Shared user model
    - [x] Implement login flow
    - [x] Persist user token in local storage and fetch it on starting the app
  - [ ] Poll Submission
  - [ ] Integrate returned errors in poll fields i.e. validation
  - [ ] Home Page / Landing page Options
    - [x] Marketing stuff 
  - [ ] Create Poll
  - [ ] PollDashboard: 
    - [ ] Aggregate and display Poll results as graphs etc. in a poll dashboard
    - [ ] Creator of the poll to manage the poll: Editing, deleting
