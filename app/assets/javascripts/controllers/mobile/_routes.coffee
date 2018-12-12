angular.module('TheArticleNG').config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state 'frontpage',
    url: '/front-page'
    templateUrl: "front-page.html"
		controller: 'FrontPageController'