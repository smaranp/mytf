data aws_availability_zones "azs"{
}
resource aws_vpc "vpc1"{
	cidr_block=var.v_vpc_cidr
	tags={
		"Name"=var.v_vpc_tag
	}
}
resource aws_subnet "sn"{
   count=length(data.aws_availability_zones.azs.names)*2
   cidr_block= cidrsubnet(var.v_vpc_cidr, 8, count.index)  
   availability_zone= data.aws_availability_zones.azs.names[count.index%length(data.aws_availability_zones.azs.names)] 
   vpc_id =aws_vpc.vpc1.id
   tags={
   "Name"=join("-",[var.v_vpc_tag,count.index<3?"Pub":"Prv",count.index+1])
   }
   
}
resource aws_internet_gateway "igw"{
	vpc_id =aws_vpc.vpc1.id
	tags={
		"Name"=var.v_vpc_tag
	}
}
resource aws_route_table "pub-rt"{
	vpc_id =aws_vpc.vpc1.id
	tags={
		"Name"=var.v_vpc_tag
	}
}
resource aws_route "addigw"{
	route_table_id =aws_route_table.pub-rt.id
	gateway_id =aws_internet_gateway.igw.id
	destination_cidr_block="0.0.0.0/0"
}
resource aws_route_table_association "pub-rt-sn"{
    count=length(data.aws_availability_zones.azs.names)
	route_table_id = aws_route_table.pub-rt.id
	subnet_id=aws_subnet.sn.*.id[count.index]
	
}

output "sns"{
	value=aws_subnet.sn.*.id
}
output "snsof"{
	value=length(aws_subnet.sn.*.id)
}

  
   