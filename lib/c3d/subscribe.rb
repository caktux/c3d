#!/usr/bin/env ruby


# Queries:
#   * `subscribe-k`:    add a contract's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `subscribe-g`:    add a group's blobs to the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `unsubscribe-k`   remove a contract's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS") (returns success: true or error)
#   * `unsubscribe-g`   remove a group's blobs from the subscribed list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)
#   * `ignore-g`        add a group to the ignore list (params: contract: "CONTRACT_ADDRESS", group: "GROUP_ID") (returns success: true or error)