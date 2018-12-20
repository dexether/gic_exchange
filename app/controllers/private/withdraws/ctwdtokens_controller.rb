module Private::Withdraws
  class CtwdtokensController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
