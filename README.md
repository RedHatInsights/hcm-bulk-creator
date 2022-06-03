# Cost Management Bulk-Uploader

**Requirements**:
- curl
- jq

This is a bulk-upload tool for importing many AWS accounts into console.redhat.com's hybrid cost management application.

To run this one needs a couple things:
1. Credentials to console.redhat.com with the `Sources Administrator` role in RBAC
2. 1..n AWS Accounts one wants to monitor with cost management

### File(s) needed
To manage these many sources in console.redhat.com the scripts just read from a csv file, by default it looks in the current directory for `accounts.csv`. The format of this document is very simple and looks like this:

| Name | AccessKey | Secret |
| -------- | -------- | ------ |
| Test1 | AK2522235 | S3CRet |

The access key + secret need to be:
- (easy way) be an admin-level iam secret, this way console.redhat.com can create the permissions/roles for cost-management to work
- (harder way) a secret that has the ability to create s3 buckets, create cost and usage reports, create roles, create policies.

caveat: if you're doing it "the harder way" you will need to check console.redhat.com to see the error that the worker returns permissions-wise.

## Creating the resources
A Makefile has been provided to make running the script easier (e.g. it checks that all of the environment variables are set correctly).

simply run `make USER=myuser PASSWORD=hunter2 INPUT=accounts.csv create` and the script will create every source under the aws account specified.

*NOTE*: Do not change the CSV file after running this command! If you want to destroy the resources later we need the names to match in order to find and destroy them.

## Destroying the resources
Much the same as creating the resources, except instead of creating it just filters the user's sources by the name and destroys that record.

`make USER=myuser PASSWORD=hunter2 INPUT=accounts.csv destroy`

tip: if something did change (e.g. someone deleted a source from the UI) the destroy script will fail. It is probably easiest to just delete that record from the CSV to delete the rest.
