#First of all we need to import csv and Networkx
import csv
import networkx as nx
#Then we need to define who is our zabbix server and some other detail to properly produce the DOT file
zabbix_service_ipaddr = "192.168.1.100"
main_loop_ipaddr = "10.12.20.1"
main_vlan_ipaddr = "149.148.56.1"

# Now we can finally create our graph
G=nx.Graph()
# we can open our CSV file
csv_reader = csv.DictReader( open( 'my_export.csv' ), \
    delimiter=",", \
    fieldnames=( "ipaddress", "hostname", "oid", "dontcare", "neighbors" ))
# Skip the header
csv_reader.next()

for row in csv_reader:
    neighbor_list = row["neighbors"].split( "," )

    for neighbor in neighbor_list:
        # Remove spaces
        neighbor = neighbor.lstrip()

  # Add neighbors,and here we’ve decided to ignore isolated nodes
        if neighbor != "":
            G.add_edge( row["ipaddress"], neighbor )

            # Add additional information to nodes or edges here
            G.node[row["ipaddress"]]["hostname"] = row["hostname"]
# Cisco Prime doesn't export all IP addresses of a device
# but only the first for each network, Here we merge hosts with
# multiple IP addresses
mapping = {main_vlan_ipaddr: main_loop_ipaddr}
G = nx.relabel_nodes( G, mapping )

# Remove cluster connection not needed in our map
G.remove_edge( "10.12.2.1", "10.12.2.2" )

# Adding connection between Zabbix server and main switch
G.add_edge( zabbix_service_ipaddr, main_loop_ipaddr )
main_neigh_list = G.neighbors( main_loop_ipaddr )
# finally write out our file
nx.draw_graphviz( G )
nx.write_dot( G, "/tmp/total.dot" )
