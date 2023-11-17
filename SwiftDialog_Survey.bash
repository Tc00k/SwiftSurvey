#!/bin/bash

####################################################################################
##
##                              Create a Dialog
##                      Swift Dialog notification builder
##                          Created by Trenton Cook
##
####################################################################################

echo ""
echo "##########################################"
echo "##        Script Initializing...          "
echo "##########################################"
echo " "

##########################################
## DIALOG NOTIFICATION PROCESSING
##########################################

## Check https://github.com/bartreardon/swiftDialog/wiki for a full list of commands and customizations for SwiftDialog
echo "-- Grabbing Dialog binary..."
echo "-- Creating Survey Result file..."
echo ""
dialogBinary="/usr/local/bin/dialog"
surveyresults="/private/var/surveyresults.txt"
tempSurveyResults="/private/var/tempsurveyresults.txt"
brandingBanner="https://img.freepik.com/free-photo/abstract-smooth-dark-blue-with-black-vignette-studio-well-use-as-backgroundbusiness-reportdigitalwebsite-templatebackdrop_1258-108839.jpg"

##########################################
## Initial Alert Variables
##########################################

echo "-- Setting Alert Variables..."
alertbutton1text="Yes"
alertbutton2text="No"
alerttitle="Feedback?"
alertmessage="Would you like to answer a quick survey about how we're doing?"
alertIcon=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist self_service_app_path )

##########################################
## Initial Alert Configuration
##########################################

echo "-- Writing Alert Data..."
alertConfig="$dialogBinary \
--title \"$alerttitle\" \
--message \"$alertmessage\" \
--button1text \"$alertbutton1text\" \
--button2text \"$alertbutton2text\" \
--messagefont 'size=18' \
--titlefont 'size=38' \
--style \"alert\" \
--icon \"$alertIcon\" \
--height '235' \
--position \"topright\" \
--ontop \
"

##########################################
## Display Alert
##########################################

## Run the dialog for Alert
echo ""
echo "-- Running Dialog for Alert..."
echo "-- Waiting for input..."
## Launches dialog with alert configurations
eval "${alertConfig}"

## Run commands based off button returns (Alert)
case $? in 
    ## Button 1 Return
    0)
    echo "-- User pressed $alertbutton1text --"
    participate="Yes"
    echo "-- User has accepted the survey prompt..."
    echo ""
    ;;
    ## Button 2 Return
    2)
    echo "-- User pressed $alertbutton2text --"
    participate="No"
    echo "-- User has opted out of Survey..."
    exit 0
    ;;
esac

##############################################
## Run Survey if user selected to participate
##############################################

if [ $participate == 'Yes' ]; then

    ##########################################
    ## Page 1 Variables
    ##########################################

    echo "-- Setting Page 1 variables..."
    page1button1text="Submit"
    page1infotext="Quit"
    page1title="Tell us how we did!"
    page1message=""
    page1Icon=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist self_service_app_path )

    ##########################################
    ## Page 2 Variables
    ##########################################

    echo "-- Setting Page 2 variables..."
    page2button1text="Close"
    page2button2text="Button 2"
    page2infotext="Info Button"
    page2title="Thanks!"
    page2message="We appreciate your feedback!"
    page2Icon=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist self_service_app_path )

    ##########################################
    ## Page 1 Configuration
    ##########################################

    echo "-- Writing Page 1 data..."
    page1Config="$dialogBinary \
    --bannertitle \"$page1title\" \
    --message \"$page1message\" \
    --bannerimage \"$brandingBanner\" \
    --icon \"$page1Icon\" \
    --button1text \"$page1button1text\" \
    --infobuttontext \"$page1infotext\" \
    --textfield \"Full Name:, required\" \
    --selecttitle \"Rate us out of 5:,required\" \
    --selectvalues \"1, 2, 3, 4, 5\" \
    --textfield \"Additional Feedback:,editor,required\" \
    --titlefont 'size=38' \
    --messagefont 'size=18' \
    --moveable \
    --iconsize '200' \
    --quitoninfo \
    --height '450' \
    --ontop \
    "

    ##########################################
    ## Page 2 Configuration
    ##########################################

        echo "-- Writing Page 2 data..."
        page2Config="$dialogBinary \
        --bannertitle \"$page2title\" \
        --message \"$page2message\" \
        --icon \"$page2Icon\" \
        --button1text \"$page2button1text\" \
        --style \"alert\" \
        --titlefont 'size=38' \
        --messagefont 'size=18' \
        --iconsize '200' \
        --quitoninfo \
        --height '250' \
        --ontop \
        "

    ##########################################
    ## Display Page 1 and evaluate returns
    ##########################################

    ## Run the Dialog for Page 1
    echo ""
    echo "-- Running Dialog for page 1..."
    echo "-- Waiting for input..."
    echo "" >> "${surveyresults}"
    ## Launches the first page dialog and copies the returns from the survey fields to a temporary file
    eval "${page1Config}" >> "${tempSurveyResults}" 2>&1

    ## Run commands based off button returns (Page 1)
    case $? in
        ## Button 1 Return
        0)
        echo "-- User Pressed $page1button1text --"
        ;;
        ## Button 2 Return
        2)
        echo "-- User Pressed $page1button2text --"
        ;;
        ## Info Button Return
        3)
        echo "-- User Pressed $page1infotext --"
        echo "-- User has opted out of the survey, closing..."
        exit 0
        ;;
    esac

    ##########################################
    ## Display Page 2 and evaluate returns
    ##########################################

    ## Run the Dialog for Page 2
        echo ""
        echo "-- Running Dialog for page 2..."
        echo "-- Waiting for input..."
        eval "${page2Config}"

        ## Run commands based off button returns (Page 2)
        case $? in 
            ## Button 1 Return
            0)
            echo "-- User Pressed $page2button1text --"
            echo ""
                ## Adjust the lines in temp file for better readability
            egrep -v 'Selected|index' "${tempSurveyResults}" >> "${surveyresults}"
                ## Paste the returned fields to a policy log in JAMF (SurveyLimpet)
            /usr/local/bin/jamf policy -event retrievesurvey
            ## Remove the temporary file
            echo ""
            echo "-- Removing all temporary files and cleaning up..."
            rm -rf $surveyresults
            rm -rf $tempSurveyResults
            ;;
            ## Button 2 Return
            2)
            echo "-- User Pressed $page2button2text --"
            ;;
            ## InfoButton Return
            3)
            echo "-- User Pressed $page2infotext --"
            ;;
        esac

    ## Notify of finalization
    echo ""
    echo "##########################################"
    echo "##           Script Complete!             "
    echo "##########################################"
    echo ""
fi