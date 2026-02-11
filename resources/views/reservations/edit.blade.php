@extends('layouts.app')
@section('title', 'Modifier Réservation #' . $reservation->id)
@section('content')
<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Modifier Réservation #{{ $reservation->id }}</h5>
            </div>
            <div class="card-body">
                <form action="{{ route('reservations.update', $reservation) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="statut">Statut</label>
                        <div class="col-sm-9">
                            <select class="form-select @error('statut') is-invalid @enderror" id="statut" name="statut" required>
                                <option value="attente" {{ old('statut', $reservation->statut->value) == 'attente' ? 'selected' : '' }}>En attente</option>
                                <option value="confirmee" {{ old('statut', $reservation->statut->value) == 'confirmee' ? 'selected' : '' }}>Confirmée</option>
                                <option value="en_cours" {{ old('statut', $reservation->statut->value) == 'en_cours' ? 'selected' : '' }}>En cours</option>
                                <option value="terminee" {{ old('statut', $reservation->statut->value) == 'terminee' ? 'selected' : '' }}>Terminée</option>
                                <option value="annulee" {{ old('statut', $reservation->statut->value) == 'annulee' ? 'selected' : '' }}>Annulée</option>
                            </select>
                            @error('statut')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>
                    
                    <hr class="my-4">

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="nom_client">Client</label>
                        <div class="col-sm-9">
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-user"></i></span>
                                <input type="text" class="form-control @error('nom_client') is-invalid @enderror" id="nom_client" name="nom_client" value="{{ old('nom_client', $reservation->nom_client) }}" required />
                                @error('nom_client')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="telephone">Téléphone</label>
                        <div class="col-sm-9">
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-phone"></i></span>
                                <input type="text" class="form-control @error('telephone') is-invalid @enderror" id="telephone" name="telephone" value="{{ old('telephone', $reservation->telephone) }}" required />
                                @error('telephone')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="email">Email (Optionnel)</label>
                        <div class="col-sm-9">
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-envelope"></i></span>
                                <input type="email" class="form-control @error('email') is-invalid @enderror" id="email" name="email" value="{{ old('email', $reservation->email) }}" />
                                @error('email')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <hr class="my-4">
                    
                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="table_id">Table</label>
                        <div class="col-sm-9">
                            <select class="form-select @error('table_id') is-invalid @enderror" id="table_id" name="table_id" required>
                                <option value="">Choisir une table...</option>
                                @foreach($tables as $table)
                                    <option value="{{ $table->id }}" {{ old('table_id', $reservation->table_id) == $table->id ? 'selected' : '' }}>
                                        Table {{ $table->numero }} ({{ $table->type->displayName }} - {{ $table->capacite }} pers.)
                                    </option>
                                @endforeach
                            </select>
                            @error('table_id')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="date_reservation">Date</label>
                        <div class="col-sm-9">
                            <input type="date" class="form-control @error('date_reservation') is-invalid @enderror" id="date_reservation" name="date_reservation" value="{{ old('date_reservation', $reservation->date_reservation->format('Y-m-d')) }}" required />
                            @error('date_reservation')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="heure_debut">Heure de début</label>
                        <div class="col-sm-9">
                            <input type="time" class="form-control @error('heure_debut') is-invalid @enderror" id="heure_debut" name="heure_debut" value="{{ old('heure_debut', $reservation->heure_debut->format('H:i')) }}" required />
                            @error('heure_debut')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="duree">Durée (heures)</label>
                        <div class="col-sm-9">
                            <input type="number" class="form-control @error('duree') is-invalid @enderror" id="duree" name="duree" value="{{ old('duree', $reservation->duree) }}" min="1" max="12" required />
                            @error('duree')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="nombre_personnes">Nombre de personnes</label>
                        <div class="col-sm-9">
                            <input type="number" class="form-control @error('nombre_personnes') is-invalid @enderror" id="nombre_personnes" name="nombre_personnes" value="{{ old('nombre_personnes', $reservation->nombre_personnes) }}" min="1" required />
                            @error('nombre_personnes')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="notes">Notes</label>
                        <div class="col-sm-9">
                            <textarea class="form-control @error('notes') is-invalid @enderror" id="notes" name="notes" rows="3">{{ old('notes', $reservation->notes) }}</textarea>
                            @error('notes')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row justify-content-end">
                        <div class="col-sm-9">
                            <button type="submit" class="btn btn-primary">Mettre à jour</button>
                            <a href="{{ route('reservations.show', $reservation) }}" class="btn btn-outline-secondary">Annuler</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
