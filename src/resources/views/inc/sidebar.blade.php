<!-- main sidebar -->
<aside class="main-sidebar">
  <section class="sidebar">
    @if (view()->exists('layouts.menu'))
      <ul class="sidebar-menu tree">
        @include ('layouts.menu')
      </ul>
    @endif
    {!! $htmlMenu !!}
  </section>
</aside> <!-- main sidebar -->
