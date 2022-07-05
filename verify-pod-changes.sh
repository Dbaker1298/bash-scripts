#!/bin/bash

echo -e "Checking Objectives..."

OBJECTIVE_NUM=0

function printresult {
  ((OBJECTIVE_NUM+=1))
  echo -e "\n----- Checking Objective $OBJECTIVE_NUM -----"
  echo -e "----- $1"
  if [ $2 -eq 0 ]; then
      echo -e "      \033[0;32m[COMPLETE]\033[0m Congrats! This objective is complete!"
  else
      echo -e "      \033[0;31m[INCOMPLETE]\033[0m This objective is not yet completed!"
  fi
}

expected="250%"
actual=$(kubectl get deployment fish -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
[[ "$actual" = "$expected" ]]
printresult "Change the rollout settings for an existing Deployment." $?

expected="fish"
actual=$(kubectl rollout history deployment/fish --revision=2 -o jsonpath='{.metadata.name}' 2>/dev/null)
[[ "$actual" = "$expected" ]]
printresult "Perform a rolling update." $?

expected="nginx:1.20.2fish"
actual=$(kubectl get deployment fish -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)$(kubectl rollout history deployment/fish --revision=3 -o jsonpath='{.metadata.name}' 2>/dev/null)
[[ "$actual" = "$expected" ]]
printresult "Roll back a Deployment to the previous version." $?
~
~

