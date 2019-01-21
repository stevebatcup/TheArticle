TheArticle.FactoryModule.factory("AccountSettings", ['RailsResource',
  (RailsResource) ->
    class AccountSettings extends RailsResource
      @configure
        url: '/account-settings'
        name: 'settings'
        interceptAuth: true
])
