<?php

namespace App\Http\Controllers;
use App\Models\Post;
use Illuminate\View\View;

class LicensePlateController extends Controller
{
    public function index(): View {
        $posts = Post::all();

        return view('home', compact("posts"));
    }

    public function post($bsx): View {
        $post = Post::where('number', $bsx)->firstOrFail();

        $title = $post->title;
        $description = $post->description;
        $content = $post->content;

        return view('post', compact('title', 'description', 'content'));
    }
}
