# Name of the resource we're selectively copying
GOOGLESERVICE_INFO_PLIST_DEBUG=GoogleService-Info-debug.plist
GOOGLESERVICE_INFO_PLIST_PROD=GoogleService-Info-prod.plist
GOOGLESERVICE_INFO_PLIST=GoogleService-Info.plist
# Get references to dev and prod versions of the GoogleService-Info.plist
# NOTE: These should only live on the file system and should NOT be part of the target (since we'll be adding them to the target manually)
GOOGLESERVICE_INFO_DEV=${PROJECT_DIR}/${TARGET_NAME}/${GOOGLESERVICE_INFO_PLIST_DEBUG}
GOOGLESERVICE_INFO_PROD=${PROJECT_DIR}/${TARGET_NAME}/${GOOGLESERVICE_INFO_PLIST_PROD}

# Make sure the dev version of GoogleService-Info.plist exists
echo "Looking for file in ${GOOGLESERVICE_INFO_DEV}"
if [ ! -f $GOOGLESERVICE_INFO_DEV ]
then
    echo "No Development GoogleService-Info.plist found. Please ensure it's in the proper directory."
    exit 1
fi

# Make sure the prod version of GoogleService-Info.plist exists
echo "Looking for file in ${GOOGLESERVICE_INFO_PROD}"
if [ ! -f $GOOGLESERVICE_INFO_PROD ]
then
    echo "No Production GoogleService-Info.plist found. Please ensure it's in the proper directory."
    exit 1
fi

# Get a reference to the destination location for the GoogleService-Info.plist
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app
echo "Will copy file to final destination: ${PLIST_DESTINATION}"

# Copy over the prod GoogleService-Info.plist for Release builds
if [ "${CONFIGURATION}" == "Release" ]
then
    echo "Using ${GOOGLESERVICE_INFO_PROD}"
    cp "${GOOGLESERVICE_INFO_PROD}" "${PLIST_DESTINATION}"
    
    echo "Renaming to ${GOOGLESERVICE_INFO_PLIST}"
    mv "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST_PROD}" "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST}"
else
    echo "Using ${GOOGLESERVICE_INFO_DEV}"
    cp "${GOOGLESERVICE_INFO_DEV}" "${PLIST_DESTINATION}"
    
    echo "Renaming to ${GOOGLESERVICE_INFO_PLIST}"
    mv "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST_DEBUG}"  "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST}"
fi

