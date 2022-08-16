*** Settings ***
Suite Setup
Suite Teardown
Force Tags        TCPROVISION
Library           RobotSPS
Variables         ../../../../variables.yaml
Resource          ../../../../SOAP/oneSetup.txt
Resource          ../../../../Resources/01__CommonResources.txt
Resource          ../../../../Resources/02__RulesAndActionsREST.txt
# Resource          ../../../../Resources/04__LifeCycleREST.txt

*** Variables ***
${tcId}           23044
${sendEDR}    true
${key1}    bucketInstance
${key2}    account
${key3}    entityCounterInstance
${key4}    OCSRecordType
${bkt_instance_list1}    updateBucketInstance
${bkt_instance_list2}    updateBucketInstanceBySubscriberId
${account_list1}    setBalanceWithSource
${account_list2}    adjustBalanceWithSourceWithMode
${account_list3}    adjustBalanceWithSourceAndTransactionIdWithMode
${counter_list}    updateEntityCounterInstance
${subscription_list1}    ResetSubscriptionAction
${LC_account_list1}    RenewSubscriptionAction
${name}    PROVISIONING_RECORD
${name2}    LIFECYCLE_RECORD
${rc1}    2001
${rc2}    2002
${rc3}    201
${rc4}    200
${rc5}    204
${distList}    sps-me

*** Test Cases ***
Create ReRateConfig
    ${distList1}    Combine Item    ${ME_NAME}
    #
    #Bucket Instance
    ${bkt_instance_list}    Combine Item    ${bkt_instance_list1}    ${bkt_instance_list2}
    ${bktInstance}    Create Bucketinstance Json        ${bkt_instance_list}
    #Log To Console    ${bktInstance}
    #
    #Accout
    ${acc_list}    Combine Item    ${account_list1}    ${account_list2}    ${account_list3}
    ${account}    Create Actionmethodmap Account Json        ${acc_list}
    #Log To Console    ${account}
    #
    #Counter Instance
    ${counter_instance_list}    Combine Item    ${counter_list}
    ${counterInst}    Create Entitycounterinstance Json        ${counter_instance_list}
    #Log To Console    ${counterInst}
    #
    # PROVISIONING RECORD
    ${action_method_map1}    create_additionalprop1_actionmethodmap_json    bucketInstance=${bktInstance}    account=${account}    entityCounterInstance=${counterInst}
    Log To Console    ${action_method_map1}
    #
    #Subscription
    ${LC_subs}    Combine Item    ${subscription_list1}  
    ${create_LCsubscription}    create_subscription_json    ${LC_subs}
    Log To Console  ${create_LCsubscription}
    #
    #LC_Account
    ${LC_account}    Combine Item    ${LC_account_list1}  
    ${create_LC_account}    create_actionmethodmap_account_json    ${LC_account}
    Log To Console  ${create_LC_account}
    #
    #
    # Lifecycle Record
    ${LC_Record}    create_actionMethodMap_json    ${create_LC_account}    ${create_LCsubscription}
    Log To Console   ${LC_Record}
    #
    ${data1}    create_additionalprop1_json    ${action_method_map1}    ${sendEDR}
    Log To Console    ${data1}
    #
    # ${data1}    Create Dictionary    ${name}    ${data1}
    # Log To Console    ${data1}
    #
    ${data2}    create_additionalprop2_json    ${LC_Record}
    Log To Console    ${data2}
    # 
    # ${data2}    Create Dictionary    ${name2}    ${data2}
    # Log To Console    ${data2}
    #  
    ${edrconfigvaluesmap}    create_edrconfigvaluesmap_json    ${data2}    $${data1}
    Log To Console   ${edrconfigvaluesmap}
    #
    #Poping from dictionary
    ${Pop_addProp1}    Pop From Dictionary    ${edrconfigvaluesmap}    additionalProp1 
    ${Pop_addProp2}    Pop From Dictionary    ${edrconfigvaluesmap}    additionalProp2  
    #
    #Adding to the disctionary
    Set To Dictionary    ${edrconfigvaluesmap}    key    ${name}    ${data1}
    Set To Dictionary    ${edrconfigvaluesmap}    key    ${name2}    ${data2}
    Log To Console    ${edrconfigvaluesmap}
    # ${data_list}    Create Dictionary   ${edrconfigvaluesmap}
    # Log To Console    ${data_list}
    #
    ${edrConfig}    Create Edrconfig Json    ${edrconfigvaluesmap}
    Log To Console   ${edrConfig}
    #
    ${OCS_resultCode}    Combine Item    ${rc1}        ${rc2}
    ${NCHF_resultCode}    Combine Item    ${rc3}    ${rc4}    ${rc5}
    #
    ${OCS_resultCode_Map}    Create Ocsrecordtype Json        ${OCS_resultCode}
    #Log To Console    ${OCS_resultCode_Map}
    #
    ${NCHF_resultCode_Map}    Create NCHFRecordType Json    ${NCHF_resultCode}
    #Log To Console    ${NCHF_resultCode_Map}
    #
    ${cdrRecordTypeMap1}    Create Cdrrecordtypemap Json    ${NCHF_resultCode_Map}    ${OCS_resultCode_Map}
    #Log To Console    ${cdrRecordTypeMap1}
    #
    ${cdrConfig}    Create Cdrconfig Json    ${cdrRecordTypeMap1}
    ${distList1}    Combine Item    ${distList}
    ${reratecreate}      create_rerateconfig_sm    distList=${distList1}   edrConfig=${edrconfigvaluesmap}   cdrConfig=${cdrConfig}   id=OnlineME${tcId}
    #Log To Console    ${reratecreate}
    Verify Rest Response Message    ${reratecreate}    Success
    Set Global Variable    ${reRateConfig}    ${reratecreate}
    
Get RerateConfig
    ${response}    get_rerateconfig_sm    OnlineME${tcId}
    Log To Console    ${response}
    Lists Should Be Equal    ${response}   ${reRateConfig}

# CreateAccount1
    # ${response}    Create Account SM    id=Acc1-${tcId}    accountType=PRE_PAID    dayOfMonth=01    dayOfWeek=MONDAY    hourOfDay=0
    # ...    meName=${ME_NAME}
    # Verify Rest Response Message    ${response}    Success   
    

    
# CreateAccount2
    # ${response}    Create Account SM    id=Acc2-${tcId}    accountType=PRE_PAID    dayOfMonth=01    dayOfWeek=MONDAY    hourOfDay=0
    # ...    meName=${ME_NAME}
    # Verify Rest Response Message    ${response}    Success
      

# CreateBucket1
    # ${GByte}    Create UnitType Json    unitTypeName=GByte    kindOfUnit=VOLUME    defaultSMUnit=true
    # ${response1}    Create BucketDefinition Json    name=NormalBkt-${tcId}    unitType=${GByte}    initialValue=50
    # Set Global Variable    ${Bkt1}    ${response1}
    
# CreateBucket2
    # ${GByte}    Create UnitType Json    unitTypeName=GByte    kindOfUnit=VOLUME    defaultSMUnit=true
    # ${response2}    Create BucketDefinition Json    name=Bucket2-${tcId}    unitType=${GByte}    initialValue=100    isCarryOver=true    maxCarryOverValueOption=ABSOLUTEVALUE
    # ...    consumptionPriority=CARRY_OVER_BUCKET    renewalPeriod=ONE_PERIOD    carryOverValue=100
    # Set Global Variable    ${Bkt2}    ${response2}
	
# CreateBucket3
	# ${GByte}    Create UnitType Json    unitTypeName=GByte    kindOfUnit=VOLUME    defaultSMUnit=true
    # ${response1}    Create BucketDefinition Json    name=NormalBkt2-${tcId}    unitType=${GByte}    initialValue=50
    # Set Global Variable    ${Bkt3}    ${response1}

# CreateCounter
    # ${uTyte}     Create UnitType Json    unitTypeName=GByte    kindOfUnit=VOLUME    defaultSMUnit=true
    # ${response1}    Create Counter SM    name=Counter_${tcId}    ocsPolicyCounter=true    unitType=${uTyte}    counterType=USAGE
    # ...    counterConsumptionType=ALL    counterScope=ALL
    # ${distList}    Combine Item    ${ME_NAME}
    # ${provresponse}    Provision Counter SM    distList=${distList}    name=Counter_${tcId}    ocsPolicyCounter=true    unitType=${uTyte}
    # ...    counterType=USAGE    counterConsumptionType=ALL    counterScope=ALL
    # Verify Rest Response Message    ${provresponse}    Success
    # Set Global Variable    ${uTyte}

# CreateTariff
    # ${data}    Create Conditions Value Json    type=STRING    value=NormalBkt-${tcId}
    # ${value}    Create Parameters Value Json    data=${data}
    # ${actParam}    Create Parameters Json    name=Data    value=${value}
    # ${actParams}    Combine Item    ${actParam}
    # ${attrInfo}    Create AttributeInfo Json    name=Bucket-Selection    resultContext=RATING
    # ${action1}    Create Actions Json    attributeInfo=${attrInfo}    parameters=${actParams}    resultContext=RATING    name=Bucket-Selection
    # ${action}    Combine Item    ${action1}
    # ${rule1}    Create Rules Json    actions=${action}    name=test_tariffplan_${tcId}
    # ${rule2}    Combine Item    ${rule1}
    # ${response1}    RobotSPS.Create Tariff Json    id=CarryoverCS_test_tariffplan_${tcId}    rules=${rule2}    name=test_tariffplan_${tcId}
    # Set Global Variable    ${TariffPlan}    ${response1}

# CreateTariff2
    # ${data}    Create Conditions Value Json    type=STRING    value=Bucket2-${tcId}
    # ${value}    Create Parameters Value Json    data=${data}
    # ${actParam}    Create Parameters Json    name=Data    value=${value}
    # ${actParams}    Combine Item    ${actParam}
    # ${attrInfo}    Create AttributeInfo Json    name=Bucket-Selection    resultContext=RATING
    # ${action2}    Create Actions Json    attributeInfo=${attrInfo}    parameters=${actParams}    resultContext=RATING    name=Bucket-Selection
    # ${action}    Combine Item    ${action2}
    # ${rule1}    Create Rules Json    actions=${action}    name=test_tariffplan2_${tcId}
    # ${rule2}    Combine Item    ${rule1}
    # ${response2}    RobotSPS.Create Tariff Json    id=CarryoverCS_test_tariffplan2_${tcId}    rules=${rule2}    name=test_tariffplan2_${tcId}
    # Set Global Variable    ${TariffPlan2}    ${response2}

# CreateCS
    # ${distList1}    Combine Item    ${ME_NAME}
    # ${pass0}    Create Passes Json    tariff=${TariffPlan}
    # ${pass1}    Create Passes Json    tariff=${TariffPlan2}
    # ${passes}    Combine Item    ${pass0}    ${pass1}
    # ${bucketDef}    Combine Item    ${Bkt1}    ${Bkt2}
    # ${cntrData}    Create Counterdefinition Json    name=Counter_${tcId}    unitType=${uTyte}    counterType=USAGE    counterScope=ALL    counterConsumptionType=ALL
    # ${counterList}    Combine Item    ${cntrData}
    # ${response1}    Create Charging SM    name=CS${tcId}    priority=${tcId}    passes=${passes}    bucketDefinition=${bucketDef}
    # Verify Rest Response Message    ${response1}    Success
    # ${chargingResponse}    Create Charging Sm    name=CS${tcId}    priority=3${tcId}    bucketDefinition=${bucketDef}    passes=${passes}    category=DefaultCategory
    # ...    counterDefinition=${counterList}
    # ${meList}    Combine Item    ${ME_NAME}
    # ${chargingResponseProv}    Provision Charging Sm    name=CS${tcId}    priority=3${tcId}    bucketDefinition=${bucketDef}    passes=${passes}    category=DefaultCategory
    # ...    distList=${distList1}    counterDefinition=${counterList}
    # ${provresponse}    Provision Charging SM    name=CS${tcId}    distList=${meList}    priority=${tcId}    passes=${passes}    bucketDefinition=${bucketDef}
    # Verify Rest Response Message    ${provresponse}    Success
    
# # Create CS with Counter
    # # ${distList1}    Combine Item    ${ME_NAME}
    # # ${unitTypeResp}    Create UnitType Json    unitTypeName=GByte    kindOfUnit=VOLUME
    # # ${bucketResp}    Create BucketDefinition Json    name=Bucket${tcId}    initialValue=5    unitType=${unitTypeResp}
    # # ${bucketList}    Combine Item    ${bucketResp}
    # # ${cntrData}    Create Counterdefinition Json    name=Counter${tcId}    unitType=${unitTypeResp}    counterType=USAGE    counterScope=ALL    counterConsumptionType=ALL
    # # ${counterList}    Combine Item    ${cntrData}
    # # ${bktAction}    CreateActionBucketSelectionJson    Bucket${tcId}
    # # ${counterAction}    CreateActionCounterSelectionJson    Counter_${tcId}
    # # ${actionList}    Combine Item    ${bktAction}    ${counterAction}
    # # ${rule1}    CreateRuleActionOnlyJson    ${actionList}    Tariff.pass0.rule0
    # # ${rulesList}    Combine Item    ${rule1}
    # # ${tariffJson}    RobotSPS.Create Tariff Json    name=Tariff1${tcId}    id=Tariff1${tcId}    rules=${rulesList}
    # # ${passesJson}    Create Passes Json    tariff=${tariffJson}
    # # ${passessList}    Combine Item    ${passesJson}
    # # ${chargingResponse}    Create Charging Sm    name=CS${tcId}    priority=3${tcId}    bucketDefinition=${bucketList}    passes=${passessList}    category=DefaultCategory
    # # ...    counterDefinition=${counterList}
    # # ${chargingResponseProv}    Provision Charging Sm    name=CS${tcId}    priority=3${tcId}    bucketDefinition=${bucketList}    passes=${passessList}    category=DefaultCategory
    # # ...    distList=${distList1}    counterDefinition=${counterList}
    # # Verify Rest Response Code    ${chargingResponse}    201
    # # Verify Rest Response Code    ${chargingResponseProv}    200

# CreateBundle1
    # ${subscriptionsList}    Combine Item    CS${tcId}
    # ${response}    RobotSPS.Create Bundle Sm    name=Bundle1_${tcId}    fee=0    chargingServiceList=${subscriptionsList}
    # ${distList}    Combine Item    ${ME_NAME}
    # ${provresponse}    Provision Bundle SM    distList=${distList}    name=Bundle1_${tcId}    fee=0    chargingServiceList=${subscriptionsList}
    # Verify Rest Response Message    ${response}    Success
    # Verify Rest Response Message    ${provresponse}    Success

# CreateBundle2
    # ${subscriptionsList}    Combine Item    CS${tcId}
    # ${response}    RobotSPS.Create Bundle SM    name=Bundle2_${tcId}    fee=0    chargingServiceList=${subscriptionsList}
    # ${distList}    Combine Item    ${ME_NAME}
    # ${provresponse}    Provision Bundle SM    distList=${distList}    name=Bundle2_${tcId}    fee=0    chargingServiceList=${subscriptionsList}
    # Verify Rest Response Message    ${response}    Success
    # Verify Rest Response Message    ${provresponse}    Success

# # device1
    # # ${identities1}    Create Identities Json    IMSI    ${tcId}00011
	# # ${identities0}    Create Identities Json    E164    ${tcId}000001
    # # ${identities}    Combine Item    ${identities0}    ${identities1}
    # # ${responseD2}    Create Device SM    id=D1-${tcId}    identities=${identities}    ocsHost=${Origin-Host}    ocsRealm=${destination-Realm}    pwdEncrypted=false
    # # ...    subscriptionIndex=0    syOCSEnabled=true    meName=${ME_NAME}
    # # Verify Rest Response Message    ${responseD2}    Success
    
# CreateDevice1
    # ${act}    Create Account Json    id=Acc1-${tcId}
    # ${bdl1}    Create Bundle Json    name=Bundle1_${tcId}
    # ${subs1}    Create Subscriptions Json    account=${act}    bundle=${bdl1}
    # ${subs}    Combine Item    ${subs1}
    # ${identities0}    Create Identities Json    E164    ${tcId}000001
    # ${identities}    Combine Item    ${identities0}
    # ${responseD2}    RobotSPS.Create Device SM    id=D1-${tcId}    identities=${identities}    pwdEncrypted=false
    # ...    subscriptionIndex=-1    syOCSEnabled=false    subscriptions=${subs}    meName=${ME_NAME}
    # Verify Rest Response Message    ${responseD2}    Success

# # device2
    # # ${identities1}    Create Identities Json    IMSI    ${tcId}00022
    # # ${identities0}    Create Identities Json    E164    ${tcId}000002
    # # ${identities}    Combine Item    ${identities0}    ${identities1}
    # # ${responseD2}    RobotSPS.Create Device SM    id=D2-${tcId}    identities=${identities}    ocsHost=${Origin-Host}    ocsRealm=${destination-Realm}    pwdEncrypted=false
    # # ...    subscriptionIndex=0    syOCSEnabled=true    meName=${ME_NAME}
    # # Verify Rest Response Message    ${responseD2}    Success

# CreateDevice2
    # ${act}    Create Account Json    id=Acc2-${tcId}
    # ${bdl1}    Create Bundle Json    name=Bundle2_${tcId}
    # ${subs1}    Create Subscriptions Json    account=${act}    bundle=${bdl1}
    # ${subs}    Combine Item    ${subs1}
    # ${identities0}    Create Identities Json    E164    ${tcId}000002
    # ${identities}    Combine Item    ${identities0}
    # ${responseD2}    RobotSPS.Create Device SM    id=D2-${tcId}    identities=${identities}    pwdEncrypted=false
    # ...    subscriptionIndex=-1    syOCSEnabled=false    subscriptions=${subs}    meName=${ME_NAME}
    # Verify Rest Response Message    ${responseD2}    Success



# Add Counter To Device1
    # ${response}    Add Counter To Device SM    id=Counter_${tcId}    deviceId=D1-${tcId}
    # Verify Rest Response Message    ${response}    Success
    
# Add Counter To Device2
    # ${response}    Add Counter To Device SM    id=Counter_${tcId}    deviceId=D2-${tcId}
    # Verify Rest Response Message    ${response}    Success

