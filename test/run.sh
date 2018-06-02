#! /bin/bash

HERE=$(PWD)
CONVOAR=$HERE/../dist/convoar.exe

DOBUILD=yes
DOCOPY=no

PROCESSING=UNOPTIMIZED

if [[ -z "$MB_REMOTEACCT" || -z "$MB_REMOTEHOST" ]] ; then
    echo "Cannot run script without MB_REMOTEACCT and MB_REMOTEHOST environment variables set"
    exit
fi
REMOTEACCT=${MB_REMOTEACCT:-mb}
REMOTEHOST=${MB_REMOTEHOST:-someplace.misterblue.com}

DOVERBOSE=""
# DOVERBOSE="--Verbose"

if [[ "$PROCESSING" == "UNOPTIMIZED" ]] ; then
    PARAMS="$DOVERBOSE "
    SUBDIR=unoptimized
fi

if [[ "$PROCESSING" == "MERGEDMATERIALS" ]] ; then
    PARAMS="$DOVERBOSE --MergeSharedMaterialMeshes true"
    SUBDIR=mergedmaterials
fi

# PARAMS=""
# PARAMS="--SeparateInstancedMeshes true --MeshShareThreshold 20 --MergeSharedMaterialMeshes true"
# PARAMS="--logGltfBuilding --verbose --LogBuilding --LogConversionStats"

REMOTEBASE=files.misterblue.com/BasilTest

OARS=""
OARS="$OARS testtest88.oar"
# OARS="$OARS PalmyraTemple.oar"
# OARS="$OARS Atropia_00.oar Atropia_01.oar Atropia_02.oar"
# OARS="$OARS Atropia_10.oar Atropia_11.oar Atropia_12.oar"
# OARS="$OARS Atropia_20.oar Atropia_21.oar Atropia_22.oar"
# OARS="$OARS IMAOutpostAlphaForest.oar IMAOutpostAlphaTerrain.oar Region-3dworlds-20170604.oar"
# OARS="$OARS universal_campus_01_0.7.3_03022012.oar"

for OAR in $OARS ; do
    cd "$HERE"
    DIR="convoar/$(basename -s .oar $OAR)/$SUBDIR"
    if [[ "$DOBUILD" == "yes" ]] ; then
        rm -rf "$DIR"
        mkdir -p "$DIR"
        cd "$DIR"
        $CONVOAR  $PARAMS "../../../$OAR"
    fi
    cd "$HERE"
    if [[ "$DOCOPY" == "yes" ]] ; then
        echo "======= copying $DIR to nyxx"
        ssh basil@nyxx "mkdir -p basil-git/Basiljs/$DIR"
        rsync -r --delete-after "${DIR}/" "basil@nyxx:basil-git/Basiljs/$DIR"
        echo "======= copying $DIR to misterblue"
        ssh ${REMOTEACCT}@${REMOTEHOST} "mkdir -p $REMOTEBASE/$DIR"
        rsync -e "/usr/bin/ssh" -r --delete-after "${DIR}/" "${REMOTEACCT}@${REMOTEHOST}:$REMOTEBASE/$DIR"
    fi
done
