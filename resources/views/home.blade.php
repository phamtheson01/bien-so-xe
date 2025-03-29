@extends('base')

@section('content')
    <div class="container mx-auto">
        <h1 class="text-[30px] font-bold">Link xem biển số xe:</h1>
        @if(!$posts->isEmpty())
            <div class="mt-4">
                @foreach($posts as $post)
                    @php
                        $number = $post->number;
                    @endphp
                    <a class="block hover:text-blue-400" href="{{ url("dich-bien-so/dich-bien-so-xe-$number") }}" title="{{ $post->title }}">{{ $post->title }}</a>
                @endforeach
            </div>
        @endif
    </div>
@endsection
