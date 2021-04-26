# Name of the resource we're selectively copying
GOOGLESERVICE_INFO_PLIST_DEBUG_NAME=GoogleService-Info-debug.plist
GOOGLESERVICE_INFO_PLIST_PROD_NAME=GoogleService-Info-prod.plist
GOOGLESERVICE_INFO_PLIST_FINAL_NAME=GoogleService-Info.plist
# Get references to dev and prod versions of the GoogleService-Info.plist
# NOTE: These should only live on the file system and should NOT be part of the target (since we'll be adding them to the target manually)
GOOGLESERVICE_INFO_DEBUG_PATH=${PROJECT_DIR}/${TARGET_NAME}/${GOOGLESERVICE_INFO_PLIST_DEBUG_NAME}
GOOGLESERVICE_INFO_PROD_PATH=${PROJECT_DIR}/${TARGET_NAME}/${GOOGLESERVICE_INFO_PLIST_PROD_NAME}

# Make sure the dev version of GoogleService-Info.plist exists
echo "Looking for file in ${GOOGLESERVICE_INFO_DEBUG_PATH}"
if [ ! -f $GOOGLESERVICE_INFO_DEBUG_PATH ]
then
    echo "No Development GoogleService-Info.plist found. Please ensure it's in the proper directory."
    exit 1
fi

# Make sure the prod version of GoogleService-Info.plist exists
echo "Looking for file in ${GOOGLESERVICE_INFO_PROD_PATH}"
if [ ! -f $GOOGLESERVICE_INFO_PROD_PATH ]
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
    echo "Using ${GOOGLESERVICE_INFO_PROD_PATH}"
    cp "${GOOGLESERVICE_INFO_PROD_PATH}" "${PLIST_DESTINATION}"
    
    echo "Renaming to ${GOOGLESERVICE_INFO_PLIST_FINAL_NAME}"
    mv "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST_PROD_NAME}" "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST_FINAL_NAME}"
else
    echo "Using ${GOOGLESERVICE_INFO_DEBUG_PATH}"
    cp "${GOOGLESERVICE_INFO_DEBUG_PATH}" "${PLIST_DESTINATION}"
    
    echo "Renaming to ${GOOGLESERVICE_INFO_PLIST_FINAL_NAME}"
    mv "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST_DEBUG_NAME}"  "${PLIST_DESTINATION}/${GOOGLESERVICE_INFO_PLIST_FINAL_NAME}"
fi

