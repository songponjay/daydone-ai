sealed class Failure {}

  class NetworkFailure extends Failure {
    final String message;

    NetworkFailure(this.message);
  }

  class ServerFailure extends Failure {
    final String message;
    final int statusCode;
    ServerFailure(this.message, this.statusCode);
  }
  /*class ServerFailure extends Failure {
    final String message;

    ServerFailure(this.message);
  }*/

  class CacheFailure extends Failure {
    final String message;

    CacheFailure(this.message);
  }


