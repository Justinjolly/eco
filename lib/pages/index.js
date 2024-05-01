const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendAddToGroupNotification = functions.firestore
    .document('groups/{groupId}')
    .onUpdate((change, context) => {
        const newValue = change.after.data();
        const oldValue = change.before.data();

        // Check what changed about the group
        const newMembers = newValue.members;
        const oldMembers = oldValue ? oldValue.members : [];

        // Determine which users are new
        const addedMembers = newMembers.filter(member => !oldMembers.includes(member));

        if (addedMembers.length > 0) {
            // Fetch tokens of the added members
            return admin.firestore().collection('users')
                .where(admin.firestore.FieldPath.documentId(), 'in', addedMembers)
                .get()
                .then(snapshot => {
                    const tokens = [];
                    snapshot.forEach(doc => {
                        tokens.push(doc.data().fcmToken); // Assuming you store tokens under 'fcmToken'
                    });

                    const notification = {
                        notification: {
                            title: 'You have been added to a group!',
                            body: `Welcome to the new group! Check out what's going on!`,
                            icon: 'your-icon-url',
                            click_action: 'FLUTTER_NOTIFICATION_CLICK' // if you want to open the app on tap
                        },
                        tokens: tokens
                    };

                    return admin.messaging().sendMulticast(notification);
                })
                .catch(error => {
                    console.log('Error fetching user tokens:', error);
                });
        } else {
            return null;
        }
    });
