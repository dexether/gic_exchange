module Private
  module Withdraws
    class GictokensController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end
