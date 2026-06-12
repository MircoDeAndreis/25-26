device_Name=("spine_1_1_1" "spine_1_1_2" "tof_1_2_1"  "tof_1_2_2" "spine_2_1_1" "spine_2_1_2")

for i in "${device_Name[@]}"
do
    kathara exec --no-stdout $i "sh ./shared/Experiment.sh"  &
done

kathara exec --no-stdout server_1_1_1 "scapy -c ./shared/tenThousandPacket.py" &

echo "WAITING 60 SECOND TO SAVE ALL PACKETS"
sleep 60
killall kathara exec

python3.13 ./shared/analisy.py  ${device_Name[@]}