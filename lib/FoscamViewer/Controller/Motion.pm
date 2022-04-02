package FoscamViewer::Controller::Motion;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub up ($self) {
  Mojo::IOLoop->subprocess->run_p( sub {
    $self->camera->move_up;
  });
  $self->render(text => 'OK');
}

sub down ($self) {
  Mojo::IOLoop->subprocess->run_p( sub {
    $self->camera->move_down;
  });
  $self->render(text => 'OK');
}

sub left ($self) {
  Mojo::IOLoop->subprocess->run_p( sub {
    $self->camera->move_left;
  });
  $self->render(text => 'OK');
}

sub right ($self) {
  Mojo::IOLoop->subprocess->run_p( sub {
    $self->camera->move_right;
  });
  $self->render(text => 'OK');
}

1;
