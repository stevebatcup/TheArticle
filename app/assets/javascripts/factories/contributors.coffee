TheArticle.FactoryModule.factory("ContributorRating", ['RailsResource',
  (RailsResource) ->
    class ContributorRating extends RailsResource
      @configure
        url: '/contributor_ratings'
        name: 'contributorrating'
        interceptAuth: true
])