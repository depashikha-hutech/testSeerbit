({
    
    doInit: function (component, event, helper) {
        helper.loadProfileData(component);
    },
    
    
    dosave: function (component, event, helper) {
        // Get the Profile attribute from the component
        var profile = component.get("v.Profile");

        // Call the Apex controller method to save the profile
        var action = component.get("c.saveProfile");
        action.setParams({
            "profileDetails": profile
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Optionally, you can handle a successful response here
                console.log("Profile saved successfully");

                // Show a success toast message
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        title: "Success!",
                        message: "Profile saved successfully.",
                        type: "success"
                    });
                    toastEvent.fire();
                } else {
                    console.error("force:showToast event is not available.");
                }
                  // Store the entered data in local storage
                localStorage.setItem("profileData", JSON.stringify(profile));

                
// Reload the data using Lightning Data Service
                component.find("recordLoader").reloadRecord();
                
                // Redirect to the Seerbit custom object record page
                var navService = component.find("navService");
                var pageReference = {
                    type: "standard__recordPage",
                    attributes: {
                        recordId: response.getReturnValue(), // Assumes your Apex method returns the record Id
                        objectApiName: "Virtual_Account__c", // Replace with your Seerbit custom object's API name
                        actionName: "view"
                    }
                };

                // Use the navigate method with $A.getCallback
                $A.getCallback(function () {
                    navService.navigate(pageReference).then(
                        function (response) {
                            console.log("Navigation successful!");
                            // Optionally, you can perform additional actions after navigation
                        },
                        function (error) {
                            console.error("Navigation error: " + error);
                        }
                    );
                });

                // Simulate a redirect using window.location.href
                window.location.href = "/lightning/o/Virtual_Account__c/list?filterName=00B8e000005l9e4EAA";
            } else if (state === "ERROR") {
                // Handle errors
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }

                // Show an error toast message
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        title: "Error",
                        message: "An error occurred while saving the profile.",
                        type: "error"
                    });
                    toastEvent.fire();
                } else {
                    console.error("force:showToast event is not available.");
                }
            }
        });

        // Enqueue the action for execution
        $A.enqueueAction(action);
    }
})