require "graphiti/open_api"
require "transproc"
require "transproc/recursion"

module Graphiti::OpenAPI
  module Functions
    extend Transproc::Registry

    import Transproc::HashTransformations
    import Transproc::Recursion

    def self.deep_reject_keys(hash, keys)
      t(:hash_recursion, t(:reject_keys, keys))[hash]
    end
  end
end
