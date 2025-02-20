##Spinup bucket: freeze

# Storage Cost:
# Standard S3 Pricing (Spinup AWS Region)
# * Storage: ~$0.023 per GB per month

# Glacier Pricing
# * Glacier Standard: ~$0.004 per GB per month
￼
##########################################################################################################
# Freeze (put files in glacier):
aws s3 cp s3://xxx/test-freeze/ s3://xxx/test-freeze/ --storage-class GLACIER --recursive

##########################################################################################################
# Restore:
# (All files in the folder)
aws s3 ls s3://xxx/test-freeze/ | awk '{print $4}' | while read file; do
  aws s3api restore-object --bucket xxx --key "test-freeze/$file" --restore-request '{"Days":7,"GlacierJobParameters":{"Tier":"Standard"}}'
done

# (only one file)
aws s3api restore-object --bucket xxx --key test-freeze/aa.fam --restore-request '{"Days":7,"GlacierJobParameters":{"Tier":"Standard"}}'

##########################################################################################################
# Checking Restore Status
aws s3api head-object --bucket xxx --key test-freeze/aa.fam

# If the file is still archived, the response won’t have a "Restore" field. If it's being restored or completed, it will contain:
# (json) "Restore": "ongoing-request=\"true\""

aws s3 ls s3://xxx/test-freeze/ | awk '{print $4}' | while read file; do
  echo "Checking restore status for: $file"
  aws s3api head-object --bucket xxx --key "test-freeze/$file" | grep "Restore"
done
￼￼
##########################################################################################################
# Delete the data (even it's in progress of restoring or in glacier deep archive)
aws s3 rm s3://xxx/test-freeze/ --recursive
# remove all delete markers, if existed
aws s3api delete-object --bucket xxx --key test-freeze/

# Check if delete marker existed
aws s3api list-object-versions --bucket xxx --prefix test-freeze/
￼
# "StorageClass": "GLACIER" confirms that these are active files, not delete markers.
# "VersionId": "null" suggests versioning is NOT enabled, meaning delete markers are not in use.
