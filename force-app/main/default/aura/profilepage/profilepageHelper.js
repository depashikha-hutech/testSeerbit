({
  loadProfileData: function (component) {
        // You can retrieve previously stored data from a source like local storage
        var storedData = JSON.parse(localStorage.getItem("profileData"));

        // If there is stored data, set it to the component attribute
        if (storedData) {
            component.set("v.Profile", storedData);
        }
    }
})