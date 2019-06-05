ActiveAdmin.register TestLeaderBoard do
  remove_filter :test, :user, :test_attempt
end
