module Private::Withdraws
  class GameashesController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
