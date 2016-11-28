#!/bin/bash -e
cd $WORKSPACE
export BUILD_REVISION=jenkins

ENABLE_DEVICE_BUILD=

if test -z $ghprbPullId; then
	echo "Could not find the environment variable ghprbPullId, so won't check if we're doing a device build."
else
	echo "Downloading labels for pull request #$ghprbPullId..."
	if curl https://api.github.com/repos/xamarin/xamarin-macios/issues/$ghprbPullId/labels > .tmp-labels; then
		echo "Labels found:"
		cat .tmp-labels | grep "\"name\":" | sed 's/name": \"//' | sed 's/.*\"\(.*\)\".*/    \1/' || true
		if grep '\"enable-device-build\"' .tmp-labels >/dev/null; then
			ENABLE_DEVICE_BUILD=1
			echo "Enabling device build because the label 'enable-device-build' was found."
		else
			echo "Not enabling device build; no label named 'enable-device-build' was found."
		fi
	else
		echo "Failed to fetch labels for the pull request $ghprbPullId, so won't check if we're doing a device build."
	fi
	rm -f .tmp-labels
fi

if test -n "$ENABLE_DEVICE_BUILD"; then
	./configure
else
	./configure --disable-ios-device
fi

time make world
