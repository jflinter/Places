#!/bin/sh

if [[ ! -f /usr/local/bin/mogenerator ]]
then
    echo "warning: mogenerator not installed, skipping model class generation"
    exit 0
fi

/usr/local/bin/mogenerator --template-var arc=true --model "${SRCROOT}/Places/Model/Places.xcdatamodeld" --base-class "PLCManagedObject" --machine-dir "${SRCROOT}/Places/Model/Generated" --human-dir "${SRCROOT}/Places/Model"
