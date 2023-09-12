output "op" {
    value = {
        vpc = module.op.vpc
        cloud-nat = module.cloud-nat.cloud-nat
        mig = module.mig.mig
        loadbalancer = module.loadbalancer.lb
        neg = module.NEG.op
    }
}