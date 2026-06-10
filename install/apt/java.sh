#!/bin/bash

MAJOR_VERSION=25

${APT:-apt} install -y openjdk-$MAJOR_VERSION
