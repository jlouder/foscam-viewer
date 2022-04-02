package FoscamViewer::Controller::Webapp;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub check_auth ($self) {
  $self->redirect_to('login') and return 0
    unless $self->is_user_authenticated;
  return 1;
}

sub snapshot ($self) {
  my $image = $self->camera->camera_command('snapPicture2',
                                            usr => $self->current_user->{username},
                                            pwd => $self->current_user->{password});
  $self->render(data => $image, format => 'jpeg');
}

sub stream ($self) {
  $self->res->headers->content_type('multipart/x-mixed-replace; boundary=BOUNDARY');
  $self->write();
  my $first_time = 1;
  my $drain = sub {
    if (!$first_time) {
      Mojo::IOLoop->subprocess->run_p(sub {
        select(undef, undef, undef, $self->config('mjpeg_refresh_seconds'));
      });
    }
    $first_time = 0;
    my $image = $self->camera->snapshot_jpeg;
    my $length = length $image;
    $self->write("--BOUNDARY\r\n");
    $self->write("Content-Type: image/jpeg\r\n");
    $self->write("Content-Length: $length\r\n\r\n");
    $self->write($image, __SUB__);
  };
  $self->$drain;
}

sub login_form ($self) {
  $self->render;
}

sub login ($self) {
  my $username = $self->param('username');
  my $password = $self->param('password');
  my $authd = $self->authenticate($self->param('username'), $self->param('password'));
  if ($authd) {
    $self->camera->set_username($username);
    $self->camera->set_password($password);
    $self->redirect_to('camera');
  }
  $self->stash(error_message => "Username or password incorrect");
  $self->render('webapp/login_form');
}

1;
