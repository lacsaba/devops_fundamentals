declare pipeline_json=$1
declare current_version=$(cat $pipeline_json | jq '. | .pipeline.version')
declare new_version=$(($current_version + 1))
declare new_file=pipeline-$(date +%m-%d-%Y-%H-%M).json
declare output=''
# remove metadata
jq 'del(.metadata)' "$pipeline_json" >tmp.$$.json && mv tmp.$$.json "$pipeline_json"
# increment version number
jq --argjson new_version ${new_version} '.pipeline.version=$new_version' "$pipeline_json" >tmp.$$.json && mv tmp.$$.json "$pipeline_json"

# update branch
declare default_branh='main'
jq --arg branchName "$branchName" '.pipeline.stages[0].actions[0].configuration.BranchName = $branchName' "$pipeline_json" >tmp.$$.json && mv tmp.$$.json "$pipeline_json"

# update owner
declare owner='John'
# jq --arg owner $owner '.pipeline.'
