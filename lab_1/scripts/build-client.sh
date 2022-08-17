#!/usr/bin/env bash

declare project_name='shop-angular-cloudfront'
declare repo='https://github.com/EPAM-JS-Competency-center/$project_name'
declare artifact_name='client-app.zip'

export ENV_CONFIGURATION='production'

cd ..
if ! [[ -d $project_name ]]; then
  echo '--- Cloning repo $repo'
  git clone $repo
fi
cd $project_name

if [[ -e $(pwd)/dist/app/$artifact_name ]]; then
  rm $(pwd)/dist/app/$artifact_name
fi
echo '--- npm install ---'
npm install
echo '--- npm run build ---'
npm run build --configuration=$ENV_CONFIGURATION
sh ../scripts/quality-check.sh
cd dist/app
echo '--- Compressing build ---'
zip -r $artifact_name *
cd ../../../scripts
echo '--- Build finished. ---'
