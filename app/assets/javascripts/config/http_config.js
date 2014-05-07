function HttpConfig($httpProvider) {
  function HttpInterceptor($rootScope, $q) {
    return {
      request: function(config) {
        $rootScope.app.state = 'loading';
        return config;
      },

      requestError: function(error) {
        $rootScope.app.state = 'ready';
        return $q.reject(error);
      },

      response: function(response) {
        $rootScope.app.state = 'ready';
        return response;
      },

      responseError: function(error) {
        $rootScope.app.state = 'ready';
        return $q.reject(error);
      }
    };
  }

  HttpInterceptor.$inject = ['$rootScope', '$q'];

  $httpProvider.interceptors.push(HttpInterceptor);
}

HttpConfig.$inject = ['$httpProvider'];
