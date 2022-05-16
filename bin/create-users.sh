SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u $SOLR_USER:$SOLR_PASS"
HOST=${SOLR_HOST:-"localhost:8983"}

ADMIN_USER=${ADMIN_USER:-admin_user}
ADMIN_U_PWD=${ADMIN_U_PWD:-myPassword}

QUERY_USER=${QUERY_USER:-query_user}
QUERY_U_PWD=${QUERY_U_PWD:-myPassword}

#creates a new file descriptor 3 that redirects to 1 (STDOUT)
exec 3>&1

# create new admin
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -H 'Content-type:application/json' -d '{
    "set-user": {
        "'$ADMIN_USER'":"'$ADMIN_U_PWD'",
        "'$QUERY_USER'":"'$QUERY_U_PWD'"
    }}' http://$HOST/solr/admin/authentication)

if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to add admin and query users"
   exit 1
fi

# Give new admin admin role
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -H 'Content-type:application/json' -d '{
   "set-user-role" : {"'$ADMIN_USER'": ["admin"] },
   "set-user-role" : {"'$QUERY_USER'": ["guest"] },
}' http://$HOST/solr/admin/authorization)

if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to set admin and guest roles"
   exit 1
fi

# Give admin role permissions
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -H 'Content-type:application/json' -d '{
  "set-permission": {"name": "all", "role":"admin"},
  "set-permission": {"name": "read", "role":"guest"}
}' http://$HOST/solr/admin/authorization)


if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to set permissions to admin and guest roles"
   exit 1
fi


# Remove solr user
SOLR_AUTH="-u $ADMIN_USER:$ADMIN_U_PWD"
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -H 'Content-type:application/json' -d '{
        "delete-user": ["'$SOLR_USER'"]
    }' http://$HOST/solr/admin/authentication)


if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to delete original $SOLR_USER"
   exit 1
fi

# Set blockUnknown to true to activate the auth
HTTP_STATUS=$(curl $SOLR_AUTH -w "%{http_code}" -o >(cat >&3) -H 'Content-type:application/json' -d  '{
    "set-property": {"blockUnknown":true}
    }' http://$HOST/solr/admin/authentication)

if [[ ! $HTTP_STATUS == 2* ]];
then
	# HTTP Status is not a 2xx code, so it is an error.
   echo "Failed to set blockUnknown to true to activate authentication"
   exit 1
fi