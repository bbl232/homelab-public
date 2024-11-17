resource "kubernetes_manifest" "namespace_metallb_system" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "labels" = {
        "pod-security.kubernetes.io/audit" = "privileged"
        "pod-security.kubernetes.io/enforce" = "privileged"
        "pod-security.kubernetes.io/warn" = "privileged"
      }
      "name" = "metallb-system"
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_bfdprofiles_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "bfdprofiles.metallb.io"
    }
    "spec" = {
      "group" = "metallb.io"
      "names" = {
        "kind" = "BFDProfile"
        "listKind" = "BFDProfileList"
        "plural" = "bfdprofiles"
        "singular" = "bfdprofile"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.passiveMode"
              "name" = "Passive Mode"
              "type" = "boolean"
            },
            {
              "jsonPath" = ".spec.transmitInterval"
              "name" = "Transmit Interval"
              "type" = "integer"
            },
            {
              "jsonPath" = ".spec.receiveInterval"
              "name" = "Receive Interval"
              "type" = "integer"
            },
            {
              "jsonPath" = ".spec.detectMultiplier"
              "name" = "Multiplier"
              "type" = "integer"
            },
          ]
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = <<-EOT
              BFDProfile represents the settings of the bfd session that can be
              optionally associated with a BGP session.
              EOT
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "BFDProfileSpec defines the desired state of BFDProfile."
                  "properties" = {
                    "detectMultiplier" = {
                      "description" = <<-EOT
                      Configures the detection multiplier to determine
                      packet loss. The remote transmission interval will be multiplied
                      by this value to determine the connection loss detection timer.
                      EOT
                      "format" = "int32"
                      "maximum" = 255
                      "minimum" = 2
                      "type" = "integer"
                    }
                    "echoInterval" = {
                      "description" = <<-EOT
                      Configures the minimal echo receive transmission
                      interval that this system is capable of handling in milliseconds.
                      Defaults to 50ms
                      EOT
                      "format" = "int32"
                      "maximum" = 60000
                      "minimum" = 10
                      "type" = "integer"
                    }
                    "echoMode" = {
                      "description" = <<-EOT
                      Enables or disables the echo transmission mode.
                      This mode is disabled by default, and not supported on multi
                      hops setups.
                      EOT
                      "type" = "boolean"
                    }
                    "minimumTtl" = {
                      "description" = <<-EOT
                      For multi hop sessions only: configure the minimum
                      expected TTL for an incoming BFD control packet.
                      EOT
                      "format" = "int32"
                      "maximum" = 254
                      "minimum" = 1
                      "type" = "integer"
                    }
                    "passiveMode" = {
                      "description" = <<-EOT
                      Mark session as passive: a passive session will not
                      attempt to start the connection and will wait for control packets
                      from peer before it begins replying.
                      EOT
                      "type" = "boolean"
                    }
                    "receiveInterval" = {
                      "description" = <<-EOT
                      The minimum interval that this system is capable of
                      receiving control packets in milliseconds.
                      Defaults to 300ms.
                      EOT
                      "format" = "int32"
                      "maximum" = 60000
                      "minimum" = 10
                      "type" = "integer"
                    }
                    "transmitInterval" = {
                      "description" = <<-EOT
                      The minimum transmission interval (less jitter)
                      that this system wants to use to send BFD control packets in
                      milliseconds. Defaults to 300ms
                      EOT
                      "format" = "int32"
                      "maximum" = 60000
                      "minimum" = 10
                      "type" = "integer"
                    }
                  }
                  "type" = "object"
                }
                "status" = {
                  "description" = "BFDProfileStatus defines the observed state of BFDProfile."
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_bgpadvertisements_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]  
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "bgpadvertisements.metallb.io"
    }
    "spec" = {
      "group" = "metallb.io"
      "names" = {
        "kind" = "BGPAdvertisement"
        "listKind" = "BGPAdvertisementList"
        "plural" = "bgpadvertisements"
        "singular" = "bgpadvertisement"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.ipAddressPools"
              "name" = "IPAddressPools"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.ipAddressPoolSelectors"
              "name" = "IPAddressPool Selectors"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.peers"
              "name" = "Peers"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.nodeSelectors"
              "name" = "Node Selectors"
              "priority" = 10
              "type" = "string"
            },
          ]
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = <<-EOT
              BGPAdvertisement allows to advertise the IPs coming
              from the selected IPAddressPools via BGP, setting the parameters of the
              BGP Advertisement.
              EOT
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "BGPAdvertisementSpec defines the desired state of BGPAdvertisement."
                  "properties" = {
                    "aggregationLength" = {
                      "default" = 32
                      "description" = "The aggregation-length advertisement option lets you “roll up” the /32s into a larger prefix. Defaults to 32. Works for IPv4 addresses."
                      "format" = "int32"
                      "minimum" = 1
                      "type" = "integer"
                    }
                    "aggregationLengthV6" = {
                      "default" = 128
                      "description" = "The aggregation-length advertisement option lets you “roll up” the /128s into a larger prefix. Defaults to 128. Works for IPv6 addresses."
                      "format" = "int32"
                      "type" = "integer"
                    }
                    "communities" = {
                      "description" = <<-EOT
                      The BGP communities to be associated with the announcement. Each item can be a standard community of the
                      form 1234:1234, a large community of the form large:1234:1234:1234 or the name of an alias defined in the
                      Community CRD.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "ipAddressPoolSelectors" = {
                      "description" = <<-EOT
                      A selector for the IPAddressPools which would get advertised via this advertisement.
                      If no IPAddressPool is selected by this or by the list, the advertisement is applied to all the IPAddressPools.
                      EOT
                      "items" = {
                        "description" = <<-EOT
                        A label selector is a label query over a set of resources. The result of matchLabels and
                        matchExpressions are ANDed. An empty label selector matches all objects. A null
                        label selector matches no objects.
                        EOT
                        "properties" = {
                          "matchExpressions" = {
                            "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                            "items" = {
                              "description" = <<-EOT
                              A label selector requirement is a selector that contains values, a key, and an operator that
                              relates the key and values.
                              EOT
                              "properties" = {
                                "key" = {
                                  "description" = "key is the label key that the selector applies to."
                                  "type" = "string"
                                }
                                "operator" = {
                                  "description" = <<-EOT
                                  operator represents a key's relationship to a set of values.
                                  Valid operators are In, NotIn, Exists and DoesNotExist.
                                  EOT
                                  "type" = "string"
                                }
                                "values" = {
                                  "description" = <<-EOT
                                  values is an array of string values. If the operator is In or NotIn,
                                  the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                  the values array must be empty. This array is replaced during a strategic
                                  merge patch.
                                  EOT
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                  "x-kubernetes-list-type" = "atomic"
                                }
                              }
                              "required" = [
                                "key",
                                "operator",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                            "x-kubernetes-list-type" = "atomic"
                          }
                          "matchLabels" = {
                            "additionalProperties" = {
                              "type" = "string"
                            }
                            "description" = <<-EOT
                            matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                            map is equivalent to an element of matchExpressions, whose key field is "key", the
                            operator is "In", and the values array contains only "value". The requirements are ANDed.
                            EOT
                            "type" = "object"
                          }
                        }
                        "type" = "object"
                        "x-kubernetes-map-type" = "atomic"
                      }
                      "type" = "array"
                    }
                    "ipAddressPools" = {
                      "description" = "The list of IPAddressPools to advertise via this advertisement, selected by name."
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "localPref" = {
                      "description" = <<-EOT
                      The BGP LOCAL_PREF attribute which is used by BGP best path algorithm,
                      Path with higher localpref is preferred over one with lower localpref.
                      EOT
                      "format" = "int32"
                      "type" = "integer"
                    }
                    "nodeSelectors" = {
                      "description" = "NodeSelectors allows to limit the nodes to announce as next hops for the LoadBalancer IP. When empty, all the nodes having  are announced as next hops."
                      "items" = {
                        "description" = <<-EOT
                        A label selector is a label query over a set of resources. The result of matchLabels and
                        matchExpressions are ANDed. An empty label selector matches all objects. A null
                        label selector matches no objects.
                        EOT
                        "properties" = {
                          "matchExpressions" = {
                            "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                            "items" = {
                              "description" = <<-EOT
                              A label selector requirement is a selector that contains values, a key, and an operator that
                              relates the key and values.
                              EOT
                              "properties" = {
                                "key" = {
                                  "description" = "key is the label key that the selector applies to."
                                  "type" = "string"
                                }
                                "operator" = {
                                  "description" = <<-EOT
                                  operator represents a key's relationship to a set of values.
                                  Valid operators are In, NotIn, Exists and DoesNotExist.
                                  EOT
                                  "type" = "string"
                                }
                                "values" = {
                                  "description" = <<-EOT
                                  values is an array of string values. If the operator is In or NotIn,
                                  the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                  the values array must be empty. This array is replaced during a strategic
                                  merge patch.
                                  EOT
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                  "x-kubernetes-list-type" = "atomic"
                                }
                              }
                              "required" = [
                                "key",
                                "operator",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                            "x-kubernetes-list-type" = "atomic"
                          }
                          "matchLabels" = {
                            "additionalProperties" = {
                              "type" = "string"
                            }
                            "description" = <<-EOT
                            matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                            map is equivalent to an element of matchExpressions, whose key field is "key", the
                            operator is "In", and the values array contains only "value". The requirements are ANDed.
                            EOT
                            "type" = "object"
                          }
                        }
                        "type" = "object"
                        "x-kubernetes-map-type" = "atomic"
                      }
                      "type" = "array"
                    }
                    "peers" = {
                      "description" = <<-EOT
                      Peers limits the bgppeer to advertise the ips of the selected pools to.
                      When empty, the loadbalancer IP is announced to all the BGPPeers configured.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                  }
                  "type" = "object"
                }
                "status" = {
                  "description" = "BGPAdvertisementStatus defines the observed state of BGPAdvertisement."
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_bgppeers_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "bgppeers.metallb.io"
    }
    "spec" = {
      "conversion" = {
        "strategy" = "Webhook"
        "webhook" = {
          "clientConfig" = {
            "service" = {
              "name" = "metallb-webhook-service"
              "namespace" = "metallb-system"
              "path" = "/convert"
            }
          }
          "conversionReviewVersions" = [
            "v1beta1",
            "v1beta2",
          ]
        }
      }
      "group" = "metallb.io"
      "names" = {
        "kind" = "BGPPeer"
        "listKind" = "BGPPeerList"
        "plural" = "bgppeers"
        "singular" = "bgppeer"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.peerAddress"
              "name" = "Address"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.peerASN"
              "name" = "ASN"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.bfdProfile"
              "name" = "BFD Profile"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.ebgpMultiHop"
              "name" = "Multi Hops"
              "type" = "string"
            },
          ]
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "BGPPeer is the Schema for the peers API."
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "BGPPeerSpec defines the desired state of Peer."
                  "properties" = {
                    "bfdProfile" = {
                      "type" = "string"
                    }
                    "ebgpMultiHop" = {
                      "description" = "EBGP peer is multi-hops away"
                      "type" = "boolean"
                    }
                    "holdTime" = {
                      "description" = "Requested BGP hold time, per RFC4271."
                      "type" = "string"
                    }
                    "keepaliveTime" = {
                      "description" = "Requested BGP keepalive time, per RFC4271."
                      "type" = "string"
                    }
                    "myASN" = {
                      "description" = "AS number to use for the local end of the session."
                      "format" = "int32"
                      "maximum" = 4294967295
                      "minimum" = 0
                      "type" = "integer"
                    }
                    "nodeSelectors" = {
                      "description" = <<-EOT
                      Only connect to this peer on nodes that match one of these
                      selectors.
                      EOT
                      "items" = {
                        "properties" = {
                          "matchExpressions" = {
                            "items" = {
                              "properties" = {
                                "key" = {
                                  "type" = "string"
                                }
                                "operator" = {
                                  "type" = "string"
                                }
                                "values" = {
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "minItems" = 1
                                  "type" = "array"
                                }
                              }
                              "required" = [
                                "key",
                                "operator",
                                "values",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                          }
                          "matchLabels" = {
                            "additionalProperties" = {
                              "type" = "string"
                            }
                            "type" = "object"
                          }
                        }
                        "type" = "object"
                      }
                      "type" = "array"
                    }
                    "password" = {
                      "description" = "Authentication password for routers enforcing TCP MD5 authenticated sessions"
                      "type" = "string"
                    }
                    "peerASN" = {
                      "description" = "AS number to expect from the remote end of the session."
                      "format" = "int32"
                      "maximum" = 4294967295
                      "minimum" = 0
                      "type" = "integer"
                    }
                    "peerAddress" = {
                      "description" = "Address to dial when establishing the session."
                      "type" = "string"
                    }
                    "peerPort" = {
                      "description" = "Port to dial when establishing the session."
                      "maximum" = 16384
                      "minimum" = 0
                      "type" = "integer"
                    }
                    "routerID" = {
                      "description" = "BGP router ID to advertise to the peer"
                      "type" = "string"
                    }
                    "sourceAddress" = {
                      "description" = "Source address to use when establishing the session."
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "myASN",
                    "peerASN",
                    "peerAddress",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "description" = "BGPPeerStatus defines the observed state of Peer."
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = false
          "subresources" = {
            "status" = {}
          }
        },
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.peerAddress"
              "name" = "Address"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.peerASN"
              "name" = "ASN"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.bfdProfile"
              "name" = "BFD Profile"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.ebgpMultiHop"
              "name" = "Multi Hops"
              "type" = "string"
            },
          ]
          "name" = "v1beta2"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "BGPPeer is the Schema for the peers API."
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "BGPPeerSpec defines the desired state of Peer."
                  "properties" = {
                    "bfdProfile" = {
                      "description" = "The name of the BFD Profile to be used for the BFD session associated to the BGP session. If not set, the BFD session won't be set up."
                      "type" = "string"
                    }
                    "connectTime" = {
                      "description" = "Requested BGP connect time, controls how long BGP waits between connection attempts to a neighbor."
                      "type" = "string"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "connect time should be between 1 seconds to 65535"
                          "rule" = "duration(self).getSeconds() >= 1 && duration(self).getSeconds() <= 65535"
                        },
                        {
                          "message" = "connect time should contain a whole number of seconds"
                          "rule" = "duration(self).getMilliseconds() % 1000 == 0"
                        },
                      ]
                    }
                    "disableMP" = {
                      "default" = false
                      "description" = "To set if we want to disable MP BGP that will separate IPv4 and IPv6 route exchanges into distinct BGP sessions."
                      "type" = "boolean"
                    }
                    "ebgpMultiHop" = {
                      "description" = "To set if the BGPPeer is multi-hops away. Needed for FRR mode only."
                      "type" = "boolean"
                    }
                    "enableGracefulRestart" = {
                      "description" = <<-EOT
                      EnableGracefulRestart allows BGP peer to continue to forward data packets along
                      known routes while the routing protocol information is being restored.
                      This field is immutable because it requires restart of the BGP session
                      Supported for FRR mode only.
                      EOT
                      "type" = "boolean"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "EnableGracefulRestart cannot be changed after creation"
                          "rule" = "self == oldSelf"
                        },
                      ]
                    }
                    "holdTime" = {
                      "description" = "Requested BGP hold time, per RFC4271."
                      "type" = "string"
                    }
                    "keepaliveTime" = {
                      "description" = "Requested BGP keepalive time, per RFC4271."
                      "type" = "string"
                    }
                    "myASN" = {
                      "description" = "AS number to use for the local end of the session."
                      "format" = "int32"
                      "maximum" = 4294967295
                      "minimum" = 0
                      "type" = "integer"
                    }
                    "nodeSelectors" = {
                      "description" = <<-EOT
                      Only connect to this peer on nodes that match one of these
                      selectors.
                      EOT
                      "items" = {
                        "description" = <<-EOT
                        A label selector is a label query over a set of resources. The result of matchLabels and
                        matchExpressions are ANDed. An empty label selector matches all objects. A null
                        label selector matches no objects.
                        EOT
                        "properties" = {
                          "matchExpressions" = {
                            "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                            "items" = {
                              "description" = <<-EOT
                              A label selector requirement is a selector that contains values, a key, and an operator that
                              relates the key and values.
                              EOT
                              "properties" = {
                                "key" = {
                                  "description" = "key is the label key that the selector applies to."
                                  "type" = "string"
                                }
                                "operator" = {
                                  "description" = <<-EOT
                                  operator represents a key's relationship to a set of values.
                                  Valid operators are In, NotIn, Exists and DoesNotExist.
                                  EOT
                                  "type" = "string"
                                }
                                "values" = {
                                  "description" = <<-EOT
                                  values is an array of string values. If the operator is In or NotIn,
                                  the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                  the values array must be empty. This array is replaced during a strategic
                                  merge patch.
                                  EOT
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                  "x-kubernetes-list-type" = "atomic"
                                }
                              }
                              "required" = [
                                "key",
                                "operator",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                            "x-kubernetes-list-type" = "atomic"
                          }
                          "matchLabels" = {
                            "additionalProperties" = {
                              "type" = "string"
                            }
                            "description" = <<-EOT
                            matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                            map is equivalent to an element of matchExpressions, whose key field is "key", the
                            operator is "In", and the values array contains only "value". The requirements are ANDed.
                            EOT
                            "type" = "object"
                          }
                        }
                        "type" = "object"
                        "x-kubernetes-map-type" = "atomic"
                      }
                      "type" = "array"
                    }
                    "password" = {
                      "description" = "Authentication password for routers enforcing TCP MD5 authenticated sessions"
                      "type" = "string"
                    }
                    "passwordSecret" = {
                      "description" = <<-EOT
                      passwordSecret is name of the authentication secret for BGP Peer.
                      the secret must be of type "kubernetes.io/basic-auth", and created in the
                      same namespace as the MetalLB deployment. The password is stored in the
                      secret as the key "password".
                      EOT
                      "properties" = {
                        "name" = {
                          "description" = "name is unique within a namespace to reference a secret resource."
                          "type" = "string"
                        }
                        "namespace" = {
                          "description" = "namespace defines the space within which the secret name must be unique."
                          "type" = "string"
                        }
                      }
                      "type" = "object"
                      "x-kubernetes-map-type" = "atomic"
                    }
                    "peerASN" = {
                      "description" = "AS number to expect from the remote end of the session."
                      "format" = "int32"
                      "maximum" = 4294967295
                      "minimum" = 0
                      "type" = "integer"
                    }
                    "peerAddress" = {
                      "description" = "Address to dial when establishing the session."
                      "type" = "string"
                    }
                    "peerPort" = {
                      "default" = 179
                      "description" = "Port to dial when establishing the session."
                      "maximum" = 16384
                      "minimum" = 0
                      "type" = "integer"
                    }
                    "routerID" = {
                      "description" = "BGP router ID to advertise to the peer"
                      "type" = "string"
                    }
                    "sourceAddress" = {
                      "description" = "Source address to use when establishing the session."
                      "type" = "string"
                    }
                    "vrf" = {
                      "description" = <<-EOT
                      To set if we want to peer with the BGPPeer using an interface belonging to
                      a host vrf
                      EOT
                      "type" = "string"
                    }
                  }
                  "required" = [
                    "myASN",
                    "peerASN",
                    "peerAddress",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "description" = "BGPPeerStatus defines the observed state of Peer."
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_communities_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "communities.metallb.io"
    }
    "spec" = {
      "group" = "metallb.io"
      "names" = {
        "kind" = "Community"
        "listKind" = "CommunityList"
        "plural" = "communities"
        "singular" = "community"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = <<-EOT
              Community is a collection of aliases for communities.
              Users can define named aliases to be used in the BGPPeer CRD.
              EOT
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "CommunitySpec defines the desired state of Community."
                  "properties" = {
                    "communities" = {
                      "items" = {
                        "properties" = {
                          "name" = {
                            "description" = "The name of the alias for the community."
                            "type" = "string"
                          }
                          "value" = {
                            "description" = <<-EOT
                            The BGP community value corresponding to the given name. Can be a standard community of the form 1234:1234
                            or a large community of the form large:1234:1234:1234.
                            EOT
                            "type" = "string"
                          }
                        }
                        "type" = "object"
                      }
                      "type" = "array"
                    }
                  }
                  "type" = "object"
                }
                "status" = {
                  "description" = "CommunityStatus defines the observed state of Community."
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_ipaddresspools_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "ipaddresspools.metallb.io"
    }
    "spec" = {
      "group" = "metallb.io"
      "names" = {
        "kind" = "IPAddressPool"
        "listKind" = "IPAddressPoolList"
        "plural" = "ipaddresspools"
        "singular" = "ipaddresspool"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.autoAssign"
              "name" = "Auto Assign"
              "type" = "boolean"
            },
            {
              "jsonPath" = ".spec.avoidBuggyIPs"
              "name" = "Avoid Buggy IPs"
              "type" = "boolean"
            },
            {
              "jsonPath" = ".spec.addresses"
              "name" = "Addresses"
              "type" = "string"
            },
          ]
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = <<-EOT
              IPAddressPool represents a pool of IP addresses that can be allocated
              to LoadBalancer services.
              EOT
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "IPAddressPoolSpec defines the desired state of IPAddressPool."
                  "properties" = {
                    "addresses" = {
                      "description" = <<-EOT
                      A list of IP address ranges over which MetalLB has authority.
                      You can list multiple ranges in a single pool, they will all share the
                      same settings. Each range can be either a CIDR prefix, or an explicit
                      start-end range of IPs.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "autoAssign" = {
                      "default" = true
                      "description" = <<-EOT
                      AutoAssign flag used to prevent MetallB from automatic allocation
                      for a pool.
                      EOT
                      "type" = "boolean"
                    }
                    "avoidBuggyIPs" = {
                      "default" = false
                      "description" = <<-EOT
                      AvoidBuggyIPs prevents addresses ending with .0 and .255
                      to be used by a pool.
                      EOT
                      "type" = "boolean"
                    }
                    "serviceAllocation" = {
                      "description" = <<-EOT
                      AllocateTo makes ip pool allocation to specific namespace and/or service.
                      The controller will use the pool with lowest value of priority in case of
                      multiple matches. A pool with no priority set will be used only if the
                      pools with priority can't be used. If multiple matching IPAddressPools are
                      available it will check for the availability of IPs sorting the matching
                      IPAddressPools by priority, starting from the highest to the lowest. If
                      multiple IPAddressPools have the same priority, choice will be random.
                      EOT
                      "properties" = {
                        "namespaceSelectors" = {
                          "description" = <<-EOT
                          NamespaceSelectors list of label selectors to select namespace(s) for ip pool,
                          an alternative to using namespace list.
                          EOT
                          "items" = {
                            "description" = <<-EOT
                            A label selector is a label query over a set of resources. The result of matchLabels and
                            matchExpressions are ANDed. An empty label selector matches all objects. A null
                            label selector matches no objects.
                            EOT
                            "properties" = {
                              "matchExpressions" = {
                                "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                                "items" = {
                                  "description" = <<-EOT
                                  A label selector requirement is a selector that contains values, a key, and an operator that
                                  relates the key and values.
                                  EOT
                                  "properties" = {
                                    "key" = {
                                      "description" = "key is the label key that the selector applies to."
                                      "type" = "string"
                                    }
                                    "operator" = {
                                      "description" = <<-EOT
                                      operator represents a key's relationship to a set of values.
                                      Valid operators are In, NotIn, Exists and DoesNotExist.
                                      EOT
                                      "type" = "string"
                                    }
                                    "values" = {
                                      "description" = <<-EOT
                                      values is an array of string values. If the operator is In or NotIn,
                                      the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                      the values array must be empty. This array is replaced during a strategic
                                      merge patch.
                                      EOT
                                      "items" = {
                                        "type" = "string"
                                      }
                                      "type" = "array"
                                      "x-kubernetes-list-type" = "atomic"
                                    }
                                  }
                                  "required" = [
                                    "key",
                                    "operator",
                                  ]
                                  "type" = "object"
                                }
                                "type" = "array"
                                "x-kubernetes-list-type" = "atomic"
                              }
                              "matchLabels" = {
                                "additionalProperties" = {
                                  "type" = "string"
                                }
                                "description" = <<-EOT
                                matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                                map is equivalent to an element of matchExpressions, whose key field is "key", the
                                operator is "In", and the values array contains only "value". The requirements are ANDed.
                                EOT
                                "type" = "object"
                              }
                            }
                            "type" = "object"
                            "x-kubernetes-map-type" = "atomic"
                          }
                          "type" = "array"
                        }
                        "namespaces" = {
                          "description" = "Namespaces list of namespace(s) on which ip pool can be attached."
                          "items" = {
                            "type" = "string"
                          }
                          "type" = "array"
                        }
                        "priority" = {
                          "description" = "Priority priority given for ip pool while ip allocation on a service."
                          "type" = "integer"
                        }
                        "serviceSelectors" = {
                          "description" = <<-EOT
                          ServiceSelectors list of label selector to select service(s) for which ip pool
                          can be used for ip allocation.
                          EOT
                          "items" = {
                            "description" = <<-EOT
                            A label selector is a label query over a set of resources. The result of matchLabels and
                            matchExpressions are ANDed. An empty label selector matches all objects. A null
                            label selector matches no objects.
                            EOT
                            "properties" = {
                              "matchExpressions" = {
                                "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                                "items" = {
                                  "description" = <<-EOT
                                  A label selector requirement is a selector that contains values, a key, and an operator that
                                  relates the key and values.
                                  EOT
                                  "properties" = {
                                    "key" = {
                                      "description" = "key is the label key that the selector applies to."
                                      "type" = "string"
                                    }
                                    "operator" = {
                                      "description" = <<-EOT
                                      operator represents a key's relationship to a set of values.
                                      Valid operators are In, NotIn, Exists and DoesNotExist.
                                      EOT
                                      "type" = "string"
                                    }
                                    "values" = {
                                      "description" = <<-EOT
                                      values is an array of string values. If the operator is In or NotIn,
                                      the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                      the values array must be empty. This array is replaced during a strategic
                                      merge patch.
                                      EOT
                                      "items" = {
                                        "type" = "string"
                                      }
                                      "type" = "array"
                                      "x-kubernetes-list-type" = "atomic"
                                    }
                                  }
                                  "required" = [
                                    "key",
                                    "operator",
                                  ]
                                  "type" = "object"
                                }
                                "type" = "array"
                                "x-kubernetes-list-type" = "atomic"
                              }
                              "matchLabels" = {
                                "additionalProperties" = {
                                  "type" = "string"
                                }
                                "description" = <<-EOT
                                matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                                map is equivalent to an element of matchExpressions, whose key field is "key", the
                                operator is "In", and the values array contains only "value". The requirements are ANDed.
                                EOT
                                "type" = "object"
                              }
                            }
                            "type" = "object"
                            "x-kubernetes-map-type" = "atomic"
                          }
                          "type" = "array"
                        }
                      }
                      "type" = "object"
                    }
                  }
                  "required" = [
                    "addresses",
                  ]
                  "type" = "object"
                }
                "status" = {
                  "description" = "IPAddressPoolStatus defines the observed state of IPAddressPool."
                  "type" = "object"
                }
              }
              "required" = [
                "spec",
              ]
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_l2advertisements_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "l2advertisements.metallb.io"
    }
    "spec" = {
      "group" = "metallb.io"
      "names" = {
        "kind" = "L2Advertisement"
        "listKind" = "L2AdvertisementList"
        "plural" = "l2advertisements"
        "singular" = "l2advertisement"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".spec.ipAddressPools"
              "name" = "IPAddressPools"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.ipAddressPoolSelectors"
              "name" = "IPAddressPool Selectors"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.interfaces"
              "name" = "Interfaces"
              "type" = "string"
            },
            {
              "jsonPath" = ".spec.nodeSelectors"
              "name" = "Node Selectors"
              "priority" = 10
              "type" = "string"
            },
          ]
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = <<-EOT
              L2Advertisement allows to advertise the LoadBalancer IPs provided
              by the selected pools via L2.
              EOT
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "L2AdvertisementSpec defines the desired state of L2Advertisement."
                  "properties" = {
                    "interfaces" = {
                      "description" = <<-EOT
                      A list of interfaces to announce from. The LB IP will be announced only from these interfaces.
                      If the field is not set, we advertise from all the interfaces on the host.
                      EOT
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "ipAddressPoolSelectors" = {
                      "description" = <<-EOT
                      A selector for the IPAddressPools which would get advertised via this advertisement.
                      If no IPAddressPool is selected by this or by the list, the advertisement is applied to all the IPAddressPools.
                      EOT
                      "items" = {
                        "description" = <<-EOT
                        A label selector is a label query over a set of resources. The result of matchLabels and
                        matchExpressions are ANDed. An empty label selector matches all objects. A null
                        label selector matches no objects.
                        EOT
                        "properties" = {
                          "matchExpressions" = {
                            "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                            "items" = {
                              "description" = <<-EOT
                              A label selector requirement is a selector that contains values, a key, and an operator that
                              relates the key and values.
                              EOT
                              "properties" = {
                                "key" = {
                                  "description" = "key is the label key that the selector applies to."
                                  "type" = "string"
                                }
                                "operator" = {
                                  "description" = <<-EOT
                                  operator represents a key's relationship to a set of values.
                                  Valid operators are In, NotIn, Exists and DoesNotExist.
                                  EOT
                                  "type" = "string"
                                }
                                "values" = {
                                  "description" = <<-EOT
                                  values is an array of string values. If the operator is In or NotIn,
                                  the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                  the values array must be empty. This array is replaced during a strategic
                                  merge patch.
                                  EOT
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                  "x-kubernetes-list-type" = "atomic"
                                }
                              }
                              "required" = [
                                "key",
                                "operator",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                            "x-kubernetes-list-type" = "atomic"
                          }
                          "matchLabels" = {
                            "additionalProperties" = {
                              "type" = "string"
                            }
                            "description" = <<-EOT
                            matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                            map is equivalent to an element of matchExpressions, whose key field is "key", the
                            operator is "In", and the values array contains only "value". The requirements are ANDed.
                            EOT
                            "type" = "object"
                          }
                        }
                        "type" = "object"
                        "x-kubernetes-map-type" = "atomic"
                      }
                      "type" = "array"
                    }
                    "ipAddressPools" = {
                      "description" = "The list of IPAddressPools to advertise via this advertisement, selected by name."
                      "items" = {
                        "type" = "string"
                      }
                      "type" = "array"
                    }
                    "nodeSelectors" = {
                      "description" = "NodeSelectors allows to limit the nodes to announce as next hops for the LoadBalancer IP. When empty, all the nodes having  are announced as next hops."
                      "items" = {
                        "description" = <<-EOT
                        A label selector is a label query over a set of resources. The result of matchLabels and
                        matchExpressions are ANDed. An empty label selector matches all objects. A null
                        label selector matches no objects.
                        EOT
                        "properties" = {
                          "matchExpressions" = {
                            "description" = "matchExpressions is a list of label selector requirements. The requirements are ANDed."
                            "items" = {
                              "description" = <<-EOT
                              A label selector requirement is a selector that contains values, a key, and an operator that
                              relates the key and values.
                              EOT
                              "properties" = {
                                "key" = {
                                  "description" = "key is the label key that the selector applies to."
                                  "type" = "string"
                                }
                                "operator" = {
                                  "description" = <<-EOT
                                  operator represents a key's relationship to a set of values.
                                  Valid operators are In, NotIn, Exists and DoesNotExist.
                                  EOT
                                  "type" = "string"
                                }
                                "values" = {
                                  "description" = <<-EOT
                                  values is an array of string values. If the operator is In or NotIn,
                                  the values array must be non-empty. If the operator is Exists or DoesNotExist,
                                  the values array must be empty. This array is replaced during a strategic
                                  merge patch.
                                  EOT
                                  "items" = {
                                    "type" = "string"
                                  }
                                  "type" = "array"
                                  "x-kubernetes-list-type" = "atomic"
                                }
                              }
                              "required" = [
                                "key",
                                "operator",
                              ]
                              "type" = "object"
                            }
                            "type" = "array"
                            "x-kubernetes-list-type" = "atomic"
                          }
                          "matchLabels" = {
                            "additionalProperties" = {
                              "type" = "string"
                            }
                            "description" = <<-EOT
                            matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
                            map is equivalent to an element of matchExpressions, whose key field is "key", the
                            operator is "In", and the values array contains only "value". The requirements are ANDed.
                            EOT
                            "type" = "object"
                          }
                        }
                        "type" = "object"
                        "x-kubernetes-map-type" = "atomic"
                      }
                      "type" = "array"
                    }
                  }
                  "type" = "object"
                }
                "status" = {
                  "description" = "L2AdvertisementStatus defines the observed state of L2Advertisement."
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "customresourcedefinition_servicel2statuses_metallb_io" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apiextensions.k8s.io/v1"
    "kind" = "CustomResourceDefinition"
    "metadata" = {
      "annotations" = {
        "controller-gen.kubebuilder.io/version" = "v0.14.0"
      }
      "name" = "servicel2statuses.metallb.io"
    }
    "spec" = {
      "group" = "metallb.io"
      "names" = {
        "kind" = "ServiceL2Status"
        "listKind" = "ServiceL2StatusList"
        "plural" = "servicel2statuses"
        "singular" = "servicel2status"
      }
      "scope" = "Namespaced"
      "versions" = [
        {
          "additionalPrinterColumns" = [
            {
              "jsonPath" = ".status.node"
              "name" = "Allocated Node"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.serviceName"
              "name" = "Service Name"
              "type" = "string"
            },
            {
              "jsonPath" = ".status.serviceNamespace"
              "name" = "Service Namespace"
              "type" = "string"
            },
          ]
          "name" = "v1beta1"
          "schema" = {
            "openAPIV3Schema" = {
              "description" = "ServiceL2Status reveals the actual traffic status of loadbalancer services in layer2 mode."
              "properties" = {
                "apiVersion" = {
                  "description" = <<-EOT
                  APIVersion defines the versioned schema of this representation of an object.
                  Servers should convert recognized schemas to the latest internal value, and
                  may reject unrecognized values.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
                  EOT
                  "type" = "string"
                }
                "kind" = {
                  "description" = <<-EOT
                  Kind is a string value representing the REST resource this object represents.
                  Servers may infer this from the endpoint the client submits requests to.
                  Cannot be updated.
                  In CamelCase.
                  More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
                  EOT
                  "type" = "string"
                }
                "metadata" = {
                  "type" = "object"
                }
                "spec" = {
                  "description" = "ServiceL2StatusSpec defines the desired state of ServiceL2Status."
                  "type" = "object"
                }
                "status" = {
                  "description" = "MetalLBServiceL2Status defines the observed state of ServiceL2Status."
                  "properties" = {
                    "interfaces" = {
                      "description" = "Interfaces indicates the interfaces that receive the directed traffic"
                      "items" = {
                        "description" = "InterfaceInfo defines interface info of layer2 announcement."
                        "properties" = {
                          "name" = {
                            "description" = "Name the name of network interface card"
                            "type" = "string"
                          }
                        }
                        "type" = "object"
                      }
                      "type" = "array"
                    }
                    "node" = {
                      "description" = "Node indicates the node that receives the directed traffic"
                      "type" = "string"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "Value is immutable"
                          "rule" = "self == oldSelf"
                        },
                      ]
                    }
                    "serviceName" = {
                      "description" = "ServiceName indicates the service this status represents"
                      "type" = "string"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "Value is immutable"
                          "rule" = "self == oldSelf"
                        },
                      ]
                    }
                    "serviceNamespace" = {
                      "description" = "ServiceNamespace indicates the namespace of the service"
                      "type" = "string"
                      "x-kubernetes-validations" = [
                        {
                          "message" = "Value is immutable"
                          "rule" = "self == oldSelf"
                        },
                      ]
                    }
                  }
                  "type" = "object"
                }
              }
              "type" = "object"
            }
          }
          "served" = true
          "storage" = true
          "subresources" = {
            "status" = {}
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_metallb_system_controller" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "controller"
      "namespace" = "metallb-system"
    }
  }
}

resource "kubernetes_manifest" "serviceaccount_metallb_system_speaker" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "speaker"
      "namespace" = "metallb-system"
    }
  }
}

resource "kubernetes_manifest" "role_metallb_system_controller" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "controller"
      "namespace" = "metallb-system"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "create",
          "delete",
          "get",
          "list",
          "patch",
          "update",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resourceNames" = [
          "memberlist",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "list",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resourceNames" = [
          "controller",
        ]
        "resources" = [
          "deployments",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "bgppeers",
        ]
        "verbs" = [
          "get",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "bfdprofiles",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "ipaddresspools",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "bgpadvertisements",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "l2advertisements",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "communities",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "role_metallb_system_pod_lister" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "Role"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "pod-lister"
      "namespace" = "metallb-system"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
        ]
        "verbs" = [
          "list",
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "secrets",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "bfdprofiles",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "bgppeers",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "l2advertisements",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "bgpadvertisements",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "ipaddresspools",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "communities",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_metallb_system_controller" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "metallb-system:controller"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
          "namespaces",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "list",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services/status",
        ]
        "verbs" = [
          "update",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "events",
        ]
        "verbs" = [
          "create",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "policy",
        ]
        "resourceNames" = [
          "controller",
        ]
        "resources" = [
          "podsecuritypolicies",
        ]
        "verbs" = [
          "use",
        ]
      },
      {
        "apiGroups" = [
          "admissionregistration.k8s.io",
        ]
        "resourceNames" = [
          "metallb-webhook-configuration",
        ]
        "resources" = [
          "validatingwebhookconfigurations",
          "mutatingwebhookconfigurations",
        ]
        "verbs" = [
          "create",
          "delete",
          "get",
          "list",
          "patch",
          "update",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "admissionregistration.k8s.io",
        ]
        "resources" = [
          "validatingwebhookconfigurations",
          "mutatingwebhookconfigurations",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resourceNames" = [
          "bfdprofiles.metallb.io",
          "bgpadvertisements.metallb.io",
          "bgppeers.metallb.io",
          "ipaddresspools.metallb.io",
          "l2advertisements.metallb.io",
          "communities.metallb.io",
        ]
        "resources" = [
          "customresourcedefinitions",
        ]
        "verbs" = [
          "create",
          "delete",
          "get",
          "list",
          "patch",
          "update",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "apiextensions.k8s.io",
        ]
        "resources" = [
          "customresourcedefinitions",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_metallb_system_speaker" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "metallb-system:speaker"
    }
    "rules" = [
      {
        "apiGroups" = [
          "metallb.io",
        ]
        "resources" = [
          "servicel2statuses",
          "servicel2statuses/status",
        ]
        "verbs" = [
          "*",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
          "endpoints",
          "nodes",
          "namespaces",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "discovery.k8s.io",
        ]
        "resources" = [
          "endpointslices",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "events",
        ]
        "verbs" = [
          "create",
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "policy",
        ]
        "resourceNames" = [
          "speaker",
        ]
        "resources" = [
          "podsecuritypolicies",
        ]
        "verbs" = [
          "use",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_metallb_system_controller" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "controller"
      "namespace" = "metallb-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "controller"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "controller"
        "namespace" = "metallb-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "rolebinding_metallb_system_pod_lister" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "pod-lister"
      "namespace" = "metallb-system"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "Role"
      "name" = "pod-lister"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "speaker"
        "namespace" = "metallb-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_metallb_system_controller" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "metallb-system:controller"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "metallb-system:controller"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "controller"
        "namespace" = "metallb-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_metallb_system_speaker" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
      }
      "name" = "metallb-system:speaker"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "metallb-system:speaker"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "speaker"
        "namespace" = "metallb-system"
      },
    ]
  }
}

resource "kubernetes_manifest" "configmap_metallb_system_metallb_excludel2" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "excludel2.yaml" = <<-EOT
      announcedInterfacesToExclude: ["^docker.*", "^cbr.*", "^dummy.*", "^virbr.*", "^lxcbr.*", "^veth.*", "^lo$", "^cali.*", "^tunl.*", "^flannel.*", "^kube-ipvs.*", "^cni.*", "^nodelocaldns.*"]
      
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name" = "metallb-excludel2"
      "namespace" = "metallb-system"
    }
  }
}

resource "kubernetes_manifest" "secret_metallb_system_metallb_webhook_cert" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "name" = "metallb-webhook-cert"
      "namespace" = "metallb-system"
    }
  }
}

resource "kubernetes_manifest" "service_metallb_system_metallb_webhook_service" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "metallb-webhook-service"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 443
          "targetPort" = 9443
        },
      ]
      "selector" = {
        "component" = "controller"
      }
    }
  }
}

resource "kubernetes_manifest" "deployment_metallb_system_controller" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
        "component" = "controller"
      }
      "name" = "controller"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "revisionHistoryLimit" = 3
      "selector" = {
        "matchLabels" = {
          "app" = "metallb"
          "component" = "controller"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "prometheus.io/port" = "7472"
            "prometheus.io/scrape" = "true"
          }
          "labels" = {
            "app" = "metallb"
            "component" = "controller"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--port=7472",
                "--log-level=info",
                "--tls-min-version=VersionTLS12",
              ]
              "env" = [
                {
                  "name" = "METALLB_ML_SECRET_NAME"
                  "value" = "memberlist"
                },
                {
                  "name" = "METALLB_DEPLOYMENT"
                  "value" = "controller"
                },
              ]
              "image" = "quay.io/metallb/controller:v0.14.8"
              "livenessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/metrics"
                  "port" = "monitoring"
                }
                "initialDelaySeconds" = 10
                "periodSeconds" = 10
                "successThreshold" = 1
                "timeoutSeconds" = 1
              }
              "name" = "controller"
              "ports" = [
                {
                  "containerPort" = 7472
                  "name" = "monitoring"
                },
                {
                  "containerPort" = 9443
                  "name" = "webhook-server"
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/metrics"
                  "port" = "monitoring"
                }
                "initialDelaySeconds" = 10
                "periodSeconds" = 10
                "successThreshold" = 1
                "timeoutSeconds" = 1
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "drop" = [
                    "all",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/tmp/k8s-webhook-server/serving-certs"
                  "name" = "cert"
                  "readOnly" = true
                },
              ]
            },
          ]
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "securityContext" = {
            "fsGroup" = 65534
            "runAsNonRoot" = true
            "runAsUser" = 65534
          }
          "serviceAccountName" = "controller"
          "terminationGracePeriodSeconds" = 0
          "volumes" = [
            {
              "name" = "cert"
              "secret" = {
                "defaultMode" = 420
                "secretName" = "metallb-webhook-cert"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "daemonset_metallb_system_speaker" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "DaemonSet"
    "metadata" = {
      "labels" = {
        "app" = "metallb"
        "component" = "speaker"
      }
      "name" = "speaker"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "metallb"
          "component" = "speaker"
        }
      }
      "template" = {
        "metadata" = {
          "annotations" = {
            "prometheus.io/port" = "7472"
            "prometheus.io/scrape" = "true"
          }
          "labels" = {
            "app" = "metallb"
            "component" = "speaker"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--port=7472",
                "--log-level=info",
              ]
              "env" = [
                {
                  "name" = "METALLB_NODE_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "spec.nodeName"
                    }
                  }
                },
                {
                  "name" = "METALLB_POD_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.name"
                    }
                  }
                },
                {
                  "name" = "METALLB_HOST"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "status.hostIP"
                    }
                  }
                },
                {
                  "name" = "METALLB_ML_BIND_ADDR"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "status.podIP"
                    }
                  }
                },
                {
                  "name" = "METALLB_ML_LABELS"
                  "value" = "app=metallb,component=speaker"
                },
                {
                  "name" = "METALLB_ML_SECRET_KEY_PATH"
                  "value" = "/etc/ml_secret_key"
                },
              ]
              "image" = "quay.io/metallb/speaker:v0.14.8"
              "livenessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/metrics"
                  "port" = "monitoring"
                }
                "initialDelaySeconds" = 10
                "periodSeconds" = 10
                "successThreshold" = 1
                "timeoutSeconds" = 1
              }
              "name" = "speaker"
              "ports" = [
                {
                  "containerPort" = 7472
                  "name" = "monitoring"
                },
                {
                  "containerPort" = 7946
                  "name" = "memberlist-tcp"
                },
                {
                  "containerPort" = 7946
                  "name" = "memberlist-udp"
                  "protocol" = "UDP"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 3
                "httpGet" = {
                  "path" = "/metrics"
                  "port" = "monitoring"
                }
                "initialDelaySeconds" = 10
                "periodSeconds" = 10
                "successThreshold" = 1
                "timeoutSeconds" = 1
              }
              "securityContext" = {
                "allowPrivilegeEscalation" = false
                "capabilities" = {
                  "add" = [
                    "NET_RAW",
                  ]
                  "drop" = [
                    "ALL",
                  ]
                }
                "readOnlyRootFilesystem" = true
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/ml_secret_key"
                  "name" = "memberlist"
                  "readOnly" = true
                },
                {
                  "mountPath" = "/etc/metallb"
                  "name" = "metallb-excludel2"
                  "readOnly" = true
                },
              ]
            },
          ]
          "hostNetwork" = true
          "nodeSelector" = {
            "kubernetes.io/os" = "linux"
          }
          "serviceAccountName" = "speaker"
          "terminationGracePeriodSeconds" = 2
          "tolerations" = [
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/master"
              "operator" = "Exists"
            },
            {
              "effect" = "NoSchedule"
              "key" = "node-role.kubernetes.io/control-plane"
              "operator" = "Exists"
            },
          ]
          "volumes" = [
            {
              "name" = "memberlist"
              "secret" = {
                "defaultMode" = 420
                "secretName" = "memberlist"
              }
            },
            {
              "configMap" = {
                "defaultMode" = 256
                "name" = "metallb-excludel2"
              }
              "name" = "metallb-excludel2"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "validatingwebhookconfiguration_metallb_webhook_configuration" {
  depends_on = [ kubernetes_manifest.namespace_metallb_system ]
  manifest = {
    "apiVersion" = "admissionregistration.k8s.io/v1"
    "kind" = "ValidatingWebhookConfiguration"
    "metadata" = {
      "name" = "metallb-webhook-configuration"
    }
    "webhooks" = [
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "metallb-webhook-service"
            "namespace" = "metallb-system"
            "path" = "/validate-metallb-io-v1beta2-bgppeer"
          }
        }
        "failurePolicy" = "Fail"
        "name" = "bgppeersvalidationwebhook.metallb.io"
        "rules" = [
          {
            "apiGroups" = [
              "metallb.io",
            ]
            "apiVersions" = [
              "v1beta2",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "bgppeers",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "metallb-webhook-service"
            "namespace" = "metallb-system"
            "path" = "/validate-metallb-io-v1beta1-bfdprofile"
          }
        }
        "failurePolicy" = "Fail"
        "name" = "bfdprofilevalidationwebhook.metallb.io"
        "rules" = [
          {
            "apiGroups" = [
              "metallb.io",
            ]
            "apiVersions" = [
              "v1beta1",
            ]
            "operations" = [
              "CREATE",
              "DELETE",
            ]
            "resources" = [
              "bfdprofiles",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "metallb-webhook-service"
            "namespace" = "metallb-system"
            "path" = "/validate-metallb-io-v1beta1-bgpadvertisement"
          }
        }
        "failurePolicy" = "Fail"
        "name" = "bgpadvertisementvalidationwebhook.metallb.io"
        "rules" = [
          {
            "apiGroups" = [
              "metallb.io",
            ]
            "apiVersions" = [
              "v1beta1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "bgpadvertisements",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "metallb-webhook-service"
            "namespace" = "metallb-system"
            "path" = "/validate-metallb-io-v1beta1-community"
          }
        }
        "failurePolicy" = "Fail"
        "name" = "communityvalidationwebhook.metallb.io"
        "rules" = [
          {
            "apiGroups" = [
              "metallb.io",
            ]
            "apiVersions" = [
              "v1beta1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "communities",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "metallb-webhook-service"
            "namespace" = "metallb-system"
            "path" = "/validate-metallb-io-v1beta1-ipaddresspool"
          }
        }
        "failurePolicy" = "Fail"
        "name" = "ipaddresspoolvalidationwebhook.metallb.io"
        "rules" = [
          {
            "apiGroups" = [
              "metallb.io",
            ]
            "apiVersions" = [
              "v1beta1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "ipaddresspools",
            ]
          },
        ]
        "sideEffects" = "None"
      },
      {
        "admissionReviewVersions" = [
          "v1",
        ]
        "clientConfig" = {
          "service" = {
            "name" = "metallb-webhook-service"
            "namespace" = "metallb-system"
            "path" = "/validate-metallb-io-v1beta1-l2advertisement"
          }
        }
        "failurePolicy" = "Fail"
        "name" = "l2advertisementvalidationwebhook.metallb.io"
        "rules" = [
          {
            "apiGroups" = [
              "metallb.io",
            ]
            "apiVersions" = [
              "v1beta1",
            ]
            "operations" = [
              "CREATE",
              "UPDATE",
            ]
            "resources" = [
              "l2advertisements",
            ]
          },
        ]
        "sideEffects" = "None"
      },
    ]
  }
}
