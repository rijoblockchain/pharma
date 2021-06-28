

./network.sh up createChannel -ca -s couchdb


./network.sh deployCC -ccn pharma -ccp ../chaincode/src/pharma/ -ccl go -ccep "OR('manufacturerMSP.peer')"