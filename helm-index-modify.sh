


source ~/helm-index-mod-vars.txt

#pull latest helm container
docker pull slvs/helm-packages:latest
#run docker container
docker run --name helm -t -d containeryard.evoforge.org/slvs/helm-packages:latest
#copy helm-charts.tar to /tmp
mkdir /tmp/helm
docker cp helm:/helm-charts.tar /tmp/helm

sleep 10

#clean up containers
docker stop helm
docker rm helm


#extract files
cd /tmp/helm
tar -xvf /tmp/helm/helm-charts.tar
rm /tmp/helm/helm-charts.tar

#modify all the index files
sed -i 's/test.com/$url/g' */index.yaml

#add mino host information
mc config host add $alias  $host $username $password

#create buckets for wrongly named folders
mc mb $alias/stable $alias/incubator $alias/rook-release $alias/chartpics


#loop for each chart folder and create bucket and uplosd files
files=`ls /tmp/helm |cut -d '-' -f 1`

for f in $files
do

if [[ $f != "kubernetes" &&   $f != "chartpics" && $f != "rookceph" ]];
then
mc mb $alias/$f
mc cp /tmp/helm/$f-charts/* $alias/$f/

fi
done

#upload wrongly names folders files
mc cp /tmp/helm/kubernetes-charts/* $alias/stable/
mc cp /tmp/helm/kubernetes-charts-incubator/* $alias/incubator/
mc cp /tmp/helm/rookceph-charts/* $alias/rook-release/
mc cp /tmp/helm/chartpics/* $alias/chartpics/

#clean up

rm -rf /tmp/helm
