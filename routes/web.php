<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LicensePlateController as LicensePlateController;

Route::get("/", [LicensePlateController::class, "index"]);
Route::get("/dich-bien-so/dich-bien-so-xe-{bsx}", [LicensePlateController::class, "post"])->where("bsx", "^(?!0{5})\d{5}$");
