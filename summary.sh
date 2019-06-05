DATE1=$(date +%Y-%m-%d -d "1 day ago")
DATE2=$(date +%Y-%m-%d -d "31 days")
TOKEN=xxx
JSON=data.json
CSV=data.csv
curl -s -H "Authorization: Basic $TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" https://flex1327-fno.flexnetoperations.com/flexnet/operations/entitlementOrders -d '{}' >$JSON
cat $JSON | json activatableItem | json -d, -a -e 'this.x=this.activatableItemData.entitledProducts.entitledProduct.find(function(i){return i.product.primaryKeys.name=="PX_ADDON_NODE"});if (this.x){this.quantity=this.x.quantity}' -c 'this.quantity&&this.activatableItemData.expirationDate' -e 'this.type="VM";this.x=this.activatableItemData.entitledProducts.entitledProduct.find(function(i){return i.product.primaryKeys.name=="PX_ADDON_PLATFORM_METAL"});if (this.x){this.type="METAL"}' entitlementId activatableItemData.activationId.id soldTo entitlementState activatableItemData.numberOfCopies activatableItemData.startDate activatableItemData.expirationDate quantity type | sort -t, -k3 >$CSV
while IFS=, read e_id a_id customer state copies start end nodes type; do
 if [[ $DATE1 < $end && $end < $DATE2 ]]; then
  echo "License for $customer expires $end - ${copies}x $nodes $type (started $start)"
 fi
done <$CSV
