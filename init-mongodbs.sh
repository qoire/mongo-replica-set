#!/bin/bash

# Data directory
DB1_DATA_DIR="/var/lib/mongo1"
DB2_DATA_DIR="/var/lib/mongo2"
DB3_DATA_DIR="/var/lib/mongo3"

# Log directory
DB1_LOG_DIR="/var/log/mongodb1"
DB2_LOG_DIR="/var/log/mongodb2"
DB3_LOG_DIR="/var/log/mongodb3"

REPLICA_SET="${REPLICA_SET_NAME:-rs0}"
LOCAL_HOST="${HOST:-localhost}"

LOCAL_DB1_PORT="${DB1_PORT:-30303}"
LOCAL_DB2_PORT="${DB2_PORT:-30304}"
LOCAL_DB3_PORT="${DB3_PORT:-30305}"

mongod \
    --dbpath "${DB1_DATA_DIR}" \
    --logpath "${DB1_LOG_DIR}/mongod.log" \
    --fork \
    --port "${LOCAL_DB1_PORT}" \
    --bind_ip_all \
    --replSet "${REPLICA_SET}"

mongod \
    --dbpath "${DB2_DATA_DIR}" \
    --logpath "${DB2_LOG_DIR}/mongod.log" \
    --fork \
    --port "${LOCAL_DB2_PORT}" \
    --bind_ip_all \
    --replSet "${REPLICA_SET}"

mongod \
    --dbpath "${DB3_DATA_DIR}" \
    --logpath "${DB3_LOG_DIR}/mongod.log" \
    --fork \
    --port "${LOCAL_DB3_PORT}" \
    --bind_ip_all \
    --replSet "${REPLICA_SET}"

# Initiating the replica set
# For simplicity, let's just loop and ping all member serially, afterwards
function ping_mongodb {
    mongo "mongodb://${LOCAL_HOST}:${LOCAL_DB1_PORT}" --eval 'db.runCommand("ping").ok'
    mongo "mongodb://${LOCAL_HOST}:${LOCAL_DB2_PORT}" --eval 'db.runCommand("ping").ok'
    mongo "mongodb://${LOCAL_HOST}:${LOCAL_DB3_PORT}" --eval 'db.runCommand("ping").ok'
}

RS_MEMBER_1="{ \"_id\": 0, \"host\": \"${LOCAL_HOST}:${LOCAL_DB1_PORT}\", \"priority\": 2 }"
RS_MEMBER_2="{ \"_id\": 1, \"host\": \"${LOCAL_HOST}:${LOCAL_DB2_PORT}\", \"priority\": 0 }"
RS_MEMBER_3="{ \"_id\": 2, \"host\": \"${LOCAL_HOST}:${LOCAL_DB3_PORT}\", \"priority\": 0 }"

echo "replica set LOCAL_HOST ${LOCAL_HOST}"
echo "replica set RS_MEMBER_1 ${RS_MEMBER_1}"
echo "replica set RS_MEMBER_2 ${RS_MEMBER_2}"
echo "replica set RS_MEMBER_3 ${RS_MEMBER_3}"

# Loop, and ping each database until we're sure they've booted
until ping_mongodb >/dev/null 2>&1; do :; done

# Initiate the 
mongo "mongodb://localhost:${LOCAL_DB1_PORT}" --eval "rs.initiate({ \"_id\": \"${REPLICA_SET}\", \"members\": [${RS_MEMBER_1}, ${RS_MEMBER_2}, ${RS_MEMBER_3}] });"