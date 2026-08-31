variable "subnet_ids" {
  description = "Subnets for EKS cluster"
  type        = list(string)
}

#node

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}


# 
# variable "cluster_name" {
#   type = string
# }

# variable "subnet_ids" {
#   type = list(string)
# }

# variable "private_subnet_ids" {
#   type = list(string)
# }

# variable "node_group_name" {
#   type = string
# }

# variable "node_instance_type" {
#   type = string
# }

# variable "desired_size" {
#   type = number
# }

# variable "min_size" {
#   type = number
# }

# variable "max_size" {
#   type = number
# }