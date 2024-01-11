# SwiftSurvey

Created by: Trenton Cook

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Checking Feedback](#checking-feedback)

## Introduction

A SwiftDialog script to retrieve feedback from a user base, intended for use within Jamf Pro

## Features

- 🗃️ Housed completely within one script, with an additional script to retrieve the survey results and post them in a Jamf log
- 📋 Logging through Jamf
- 😄 User friendly GUI
- 💻 Made specifically for a Jamf Pro environment
- ✔️ Easy to setup

## Getting Started

Follow the below steps to get SwiftSurvey setup and running

### Prerequisites

Make sure you have the following:

- Jamf Instance with the target computer(s) added
- SwiftDialog installed on the target computer(s) (https://github.com/swiftDialog/swiftDialog)

### Installation

1. Add "SwiftDialog_Survey.bash" as a script to your Jamf instance
2. Add the available extension attribute to your Jamf instance
3. Create a policy for the Survey script and scope it to the machines you would like to participate in the survey.
4. Add a trigger for the "SwiftDialog_Survey" policy (I have mine set in Self Service so users are always able to report feedback)
5. Do a test run of the "SwiftDialog_Survey" policy on a target machine and take note of what you would like to be changed
6. Set a minimum score for the Rating out of 5 section under line 25
7. Make the required changes to the dialog text in the SwiftDialog_Survey.bash script on your Jamf instance ( The configuration & variable sections for "Alert" "Page 1" and "Page 2" have all the current text for the dialog window )
8. Create a smart group that is scoped to any machines that have the "sad" result in the extension attribute mentioned above. This way if a computer has the minimum score flag they enter this smart group for tracking of users that were exceptionally dissatisfied

### Usage

Computers who are hit with the Survey policy now will receive an alert window in the top right (by default) of their screen asking if they would like to submit feedback

![Screenshot 2023-11-17 at 11 12 05 AM](https://github.com/Tc00k/SwiftSurvey/assets/150291395/7a9b7bed-baab-490e-9c2c-4ea2391305b5)

If they press No, the prompt closes and reports back to the "SwiftDialog_Survey" policy that the user has prompted out of the survey

If they press Yes, the prompt reopens with a spot to enter their full name, their additional feedback in survey form, and an out-of-five rating section (all required by default)

![Screenshot 2023-11-17 at 11 13 52 AM](https://github.com/Tc00k/SwiftSurvey/assets/150291395/3c3bddf5-1da6-417b-af01-69d852da7a54)

When they submit the feedback they are greeted with a closing window, and the survey results are scanned and uploaded to the jamf log for the survey policy

![Screenshot 2023-11-17 at 11 14 57 AM](https://github.com/Tc00k/SwiftSurvey/assets/150291395/a6a7cc79-6a25-4aec-ace2-030e5d7a8285)

## Checking Feedback

When users enter their feedback their answers are automatically uploaded to their individual user policy logs, meaning that if you go to the policy we set up in step 3 of [Installation](#installation) and click "Logs" in the bottom right you can search by user name and find their answers in their logs.

Additionally, when a user enters a rating out of five below the $alertScoreMinimum stated in line 25, a tiny text file is deposited on their machine which is linked to the extension attribute you uploaded in step 2 of [Installation](#installation). Which if they are below the $alertScoreMinimum it will sort the user into the Smart Group we have setup as another form of tracking particularly negative feedback.
