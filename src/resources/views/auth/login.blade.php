@extends('back-project::layouts.enter')

@push('body_classes')
login-page
@endpush

@section('content')
    <div class="login-box">
        <div class="login-logo">
            <a href="{{config('app.url')}}">{{config('app.name') }}</a>
        </div>
        <!-- /.login-logo -->

        <div class="login-box-body">
            <p class="login-box-msg">{{ trans('back-project::base.login_message') }}</p>

            <form role="form" method="POST" action="{{ url('login') }}">
                {{ csrf_field() }}

                <div class="form-group has-feedback{{ $errors->has('email') ? ' has-error' : '' }}">
                    <input id="email" type="email" class="form-control" name="email" value="{{ old('email') }}"
                           placeholder="{{ trans('back-project::base.email_address') }}" required autofocus>
                    <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
                    @if ($errors->has('email'))
                        <span class="help-block">
                    <strong>{{ $errors->first('email') }}</strong>
                </span>
                    @endif
                </div>

                <div class="form-group has-feedback{{ $errors->has('password') ? ' has-error' : '' }}">
                    <input id="password" type="password" class="form-control" name="password"
                           value="{{ old('password') }}" placeholder="{{ trans('back-project::base.password') }}"
                           required>
                    <span class="glyphicon glyphicon-lock form-control-feedback"></span>
                    @if ($errors->has('password'))
                        <span class="help-block">
                    <strong>{{ $errors->first('password') }}</strong>
                </span>
                    @endif
                </div>

                <div class="row">
                    <div class="col-xs-8">
                        <div class="checkbox icheck">
                            <label>
                                <input type="checkbox"
                                       name="remember" {{ old('remember') ? 'checked' : ''}}> {{ trans('back-project::base.remember_me') }}
                            </label>
                        </div>
                    </div>
                    <!-- /.col -->
                    <div class="col-xs-4">
                        <button type="submit"
                                class="btn btn-primary btn-block btn-flat">{{ trans('back-project::base.login') }}</button>
                    </div>
                    <!-- /.col -->
                </div>

            </form>
            <div class="row">
                <div class="col-xs-12">
                    <br>
                    <a href="{{ url('password/reset') }}">{{ trans('back-project::base.forgot_your_password') }}</a><br>
                    <a href="{{ url('register') }}" class="text-center">{{ trans('back-project::base.register') }}</a>
                </div>
            </div>

            @if (config('back-project.social_login_enabled.facebook'))
                <div class="row">
                    <div class="col-xs-12">
                        <br>
                        <a href="{{ route('bp.social_login', ['facebook']) }}" class="btn btn-block btn-flat btn-social btn-facebook">
                            {!! @icon('facebook') !!} {{ trans('back-project::base.facebook_login') }}
                        </a>
                    </div>
                </div>
            @endif

            @if (config('back-project.social_login_enabled.twitter'))
                <div class="row">
                    <div class="col-xs-12">
                        <br>
                        <a href="{{ route('bp.social_login', ['twitter']) }}" class="btn btn-block btn-flat btn-social btn-twitter">
                            {!! @icon('twitter') !!} {{ trans('back-project::base.twitter_login') }}
                        </a>
                    </div>
                </div>
            @endif

            @if (config('back-project.social_login_enabled.linkedin'))
                <div class="row">
                    <div class="col-xs-12">
                        <br>
                        <a href="{{ route('bp.social_login', ['linkedin']) }}" class="btn btn-block btn-flat btn-social btn-linkedin">
                            {!! @icon('linkedin') !!} {{ trans('back-project::base.linkedin_login') }}
                        </a>
                    </div>
                </div>
            @endif

        </div>
        <!-- /.login-box-body -->

    </div>
    <!-- /.login-box -->

@endsection
