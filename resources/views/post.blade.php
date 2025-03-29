@extends('base')

@section('content')
    <div class="container mx-auto">
        @if(!empty($title))
            <h1 class="text-[30px] font-bold">Title: {{ $title }}</h1>
        @endif
        @if(!empty($description))
            <p class="mt-4">Description: {{ $description }}</p>
        @endif
        @if(!empty($content))
            <div class="mt-4">{{ $content }}</div>
        @endif
    </div>
@endsection
