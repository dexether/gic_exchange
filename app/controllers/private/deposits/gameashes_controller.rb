module Private
  module Deposits
    class GameashesController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
