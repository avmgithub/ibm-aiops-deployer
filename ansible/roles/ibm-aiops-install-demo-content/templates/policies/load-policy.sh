    export AIOPS_NAMESPACE=$(oc get po -A|grep aiops-orchestrator-controller |awk '{print$1}')

    export POLICY_USERNAME=$(oc get secret -n $AIOPS_NAMESPACE aiops-ir-lifecycle-policy-registry-svc -o jsonpath='{.data.username}' | base64 --decode)
    export POLICY_PASSWORD=$(oc get secret -n $AIOPS_NAMESPACE aiops-ir-lifecycle-policy-registry-svc -o jsonpath='{.data.password}' | base64 --decode)
    export POLICY_LOGIN="$POLICY_USERNAME:$POLICY_PASSWORD"
    echo $POLICY_LOGIN

    oc create route passthrough --insecure-policy="Redirect" policy-api -n $AIOPS_NAMESPACE --service aiops-ir-lifecycle-policy-registry-svc --port ssl-port

    export POLICY_ROUTE=$(oc get routes -n $AIOPS_NAMESPACE policy-api -o jsonpath="{['spec']['host']}")
    echo $POLICY_ROUTE

    export result=$(curl -XGET -k -s "https://$POLICY_ROUTE/policyregistry.ibm-netcool-prod.aiops.io/v1alpha/system/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/"  \
      -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
      -H 'content-type: application/json' \
      -u $POLICY_LOGIN|grep "DEMO Incident creation policy for all alerts"|wc -l|tr -d ' ')

    export POLICY_FILE="./ansible/roles/ibm-aiops-install-demo-content/templates/policies/temporal1.json"
    echo $POLICY_FILE
    cp $POLICY_FILE /tmp/temporal_policy.json

      export result=$(curl -XPOST -k -s "https://$POLICY_ROUTE/policyregistry.ibm-netcool-prod.aiops.io/v1alpha/system/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/policies"  \
        -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
        -H 'content-type: application/json' \
        -u $POLICY_LOGIN \
        -d @/tmp/temporal_policy.json)
 
    echo $result

exit 1

curl -XDELETE-k  "https://$POLICY_ROUTE/policyregistry.ibm-netcool-prod.aiops.io/v1alpha/system/cfd95b7e-3bc7-4006-a4a8-a73a79c71255/policies/81e2cc20-15cc-11ee-a5e0-c364c38e41d4"  \
        -H 'X-TenantID: cfd95b7e-3bc7-4006-a4a8-a73a79c71255' \
        -H 'content-type: application/json' \
        -u $POLICY_LOGIN 